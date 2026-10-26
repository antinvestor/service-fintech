// Copyright 2023-2026 Ant Investor Ltd
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

package business

import (
	"context"
	"errors"
	"fmt"
	"io"
	"slices"
	"strconv"
	"strings"
	"time"

	commonv1 "buf.build/gen/go/antinvestor/common/protocolbuffers/go/common/v1"
	"buf.build/gen/go/antinvestor/field/connectrpc/go/v2/field/v1/fieldv1connect"
	fieldv1 "buf.build/gen/go/antinvestor/field/protocolbuffers/go/field/v1"
	"buf.build/gen/go/antinvestor/loans/connectrpc/go/v2/loans/v1/loansv1connect"
	loansv1 "buf.build/gen/go/antinvestor/loans/protocolbuffers/go/loans/v1"
	"buf.build/gen/go/antinvestor/profile/connectrpc/go/v2/profile/v1/profilev1connect"
	profilev1 "buf.build/gen/go/antinvestor/profile/protocolbuffers/go/profile/v1"
	"github.com/pitabwire/frame/v3/security"
	"github.com/pitabwire/util"
	"github.com/pitabwire/util/moneyx"

	"github.com/antinvestor/service-fintech/apps/seed/service/models"
	"github.com/antinvestor/service-fintech/apps/seed/service/repository"
	"github.com/antinvestor/service-fintech/apps/seed/service/ussd"
	"github.com/antinvestor/service-fintech/pkg/messages"
	"github.com/antinvestor/service-fintech/pkg/notify"
)

// PIN policy.
const (
	ussdMaxPinAttempts = 5
	ussdPinLockout     = time.Hour
	// A new code is sent at most once a minute; a code lives ten minutes.
	ussdCodeResendAfter = time.Minute
	ussdCodeLifetime    = 10 * time.Minute
	ussdActorType       = "client_ussd"
	ussdNotifyKind      = "ussd"
)

// UssdSession is a completed USSD session handed to Seed: who made it (the
// caller's profile and the contact they dialled from) and what they chose.
// Secret inputs arrive sealed for Seed.
type UssdSession struct {
	// ID is the inbound notification's id; it keys the loan request so a
	// redelivered session never borrows twice.
	ID        string
	ProfileID string
	ContactID string
	Data      map[string]string
}

// UssdBusiness acts on borrowers' USSD sessions and keeps what the menu
// shows them current.
type UssdBusiness interface {
	HandleSession(ctx context.Context, s UssdSession) error
	// State is what the menu shows the borrower now, by row name. The USSD
	// engine asks for it when the borrower opens the menu; every name is
	// present, so a row that no longer applies is cleared.
	State(ctx context.Context, profileID string) (map[string][]map[string]any, error)
}

// UssdDeps wires the USSD business.
type UssdDeps struct {
	Opener       *ussd.Opener
	Pins         repository.UssdPinRepository
	Field        fieldv1connect.FieldServiceClient
	Loans        loansv1connect.LoanManagementServiceClient
	Profiles     profilev1connect.ProfileServiceClient
	LoanRequests LoanRequestBusiness
	Credit       CreditProfileBusiness
	Notifier     *notify.Notifier
	ProductID    string
	Currency     string
	LenderName   string
	// ServiceSubject is Seed's service account, acting for the borrower.
	ServiceSubject string
}

type ussdBusiness struct {
	d UssdDeps
}

// NewUssdBusiness returns the USSD business, or nil when USSD is off.
func NewUssdBusiness(d UssdDeps) UssdBusiness {
	if d.Opener == nil {
		return nil
	}
	return &ussdBusiness{d: d}
}

var (
	errUssdUnknownBorrower = errors.New("ussd: caller is not a seed client")
	errUssdNoLoan          = errors.New("ussd: borrower has no loan to repay")
)

func (b *ussdBusiness) HandleSession(ctx context.Context, s UssdSession) error {
	logger := util.Log(ctx).WithField("session", s.ID).WithField("profile_id", s.ProfileID)
	if s.ProfileID == "" || s.ContactID == "" {
		return nil
	}
	client, err := b.clientFor(ctx, s.ProfileID)
	if errors.Is(err, errUssdUnknownBorrower) {
		logger.Info("ussd session from a caller who is not a seed client")
		return nil
	}
	if err != nil {
		return err
	}
	ctx = b.actFor(ctx, client)

	switch {
	case s.Data[ussd.KeyPinStep] == ussd.PinSendCode:
		err = b.sendCode(ctx, s)
	case s.Data[ussd.KeyOTP] != "" && s.Data[ussd.KeyNewPIN] != "":
		err = b.setPIN(ctx, s)
	case s.Data[ussd.KeyAmount] != "" && s.Data[ussd.KeyPIN] != "":
		err = b.borrow(ctx, s, client)
	case s.Data[ussd.KeyPayOption] != "":
		err = b.repay(ctx, s, client)
	default:
		// Looking at the loan or help: nothing to do.
	}
	return err
}

// actFor runs the rest of the session as Seed's service account inside the
// borrower's own partition, so what it creates is the lender's, not the
// platform's, and row security applies.
func (b *ussdBusiness) actFor(ctx context.Context, client *fieldv1.ClientObject) context.Context {
	claims := &security.AuthenticationClaims{
		TenantID:    client.GetTenantId(),
		PartitionID: client.GetPartitionId(),
		Roles:       []string{security.ConstantSystemInternalRole},
	}
	claims.Subject = b.d.ServiceSubject
	return claims.ClaimsToContext(ctx, security.WithoutInternalTenancySkip())
}

// clientFor finds the one seed client registered on the profile.
func (b *ussdBusiness) clientFor(ctx context.Context, profileID string) (*fieldv1.ClientObject, error) {
	stream, err := b.d.Field.ClientSearch(ctx, &fieldv1.ClientSearchRequest{ProfileId: profileID})
	if err != nil {
		return nil, fmt.Errorf("find client for profile: %w", err)
	}
	defer func() { _ = stream.Close() }()
	var found []*fieldv1.ClientObject
	for {
		msg, recvErr := stream.Receive()
		if errors.Is(recvErr, io.EOF) {
			break
		}
		if recvErr != nil {
			return nil, fmt.Errorf("find client for profile: %w", recvErr)
		}
		for _, c := range msg.GetData() {
			if c.GetProfileId() == profileID && c.GetState() != commonv1.STATE_DELETED {
				found = append(found, c)
			}
		}
	}
	if len(found) != 1 {
		return nil, errUssdUnknownBorrower
	}
	return found[0], nil
}

// --- PIN --------------------------------------------------------------------

func (b *ussdBusiness) sendCode(ctx context.Context, s UssdSession) error {
	pin, err := b.d.Pins.Ensure(ctx, s.ProfileID)
	if err != nil {
		return err
	}
	if pin.VerificationRequestedAt != nil && time.Since(*pin.VerificationRequestedAt) < ussdCodeResendAfter {
		return nil
	}
	verificationID := util.IDString()
	if _, err = b.d.Profiles.CreateContactVerification(ctx, &profilev1.CreateContactVerificationRequest{
		Id:               verificationID,
		ContactId:        s.ContactID,
		DurationToExpire: ussdCodeLifetime.String(),
	}); err != nil {
		return fmt.Errorf("send pin code: %w", err)
	}
	return b.d.Pins.RecordVerification(ctx, pin.GetID(), verificationID, time.Now())
}

func (b *ussdBusiness) setPIN(ctx context.Context, s UssdSession) error {
	code, err := b.d.Opener.Open(s.Data[ussd.KeyOTP])
	if err != nil {
		return b.refuse(ctx, s, "we could not read your code. Please try again.", err)
	}
	newPIN, err := b.d.Opener.Open(s.Data[ussd.KeyNewPIN])
	if err != nil {
		return b.refuse(ctx, s, "we could not read your PIN. Please try again.", err)
	}
	confirm, err := b.d.Opener.Open(s.Data[ussd.KeyConfirmPIN])
	if err != nil || confirm != newPIN {
		return b.refuse(ctx, s, "the two PINs you entered did not match. Your PIN was not set.", nil)
	}
	if !ussd.ValidPIN(newPIN) {
		return b.refuse(ctx, s, "a PIN is 4 to 6 digits. Your PIN was not set.", nil)
	}

	pin, err := b.d.Pins.GetByProfile(ctx, s.ProfileID)
	if err != nil {
		return err
	}
	if pin == nil || pin.VerificationID == "" || pin.VerificationRequestedAt == nil ||
		time.Since(*pin.VerificationRequestedAt) > ussdCodeLifetime {
		return b.refuse(ctx, s, "your code has expired. Ask for a new code and try again.", nil)
	}
	check, err := b.d.Profiles.CheckVerification(ctx, &profilev1.CheckVerificationRequest{
		Id: pin.VerificationID, Code: code,
	})
	if err != nil || !check.GetSuccess() {
		return b.refuse(ctx, s, "the code you entered was wrong. Your PIN was not set.", err)
	}

	hash, err := ussd.HashPIN(newPIN)
	if err != nil {
		return err
	}
	if err = b.d.Pins.SetPin(ctx, pin.GetID(), hash); err != nil {
		return err
	}
	b.d.Notifier.SendOrLog(ctx, notify.Message{
		Template:  messages.UssdPinSet,
		Kind:      ussdNotifyKind,
		Recipient: notify.ToContact(s.ContactID),
		Vars:      map[string]any{messages.VarLenderName: b.d.LenderName},
	})
	return nil
}

// checkPIN verifies the borrower's PIN, counting failures toward a lock.
// It reports a refusal (already texted) as ok=false with a nil error.
func (b *ussdBusiness) checkPIN(ctx context.Context, s UssdSession) (bool, error) {
	entered, err := b.d.Opener.Open(s.Data[ussd.KeyPIN])
	if err != nil {
		return false, b.refuse(ctx, s, "we could not read your PIN. Your request was not sent.", err)
	}
	pin, err := b.d.Pins.GetByProfile(ctx, s.ProfileID)
	if err != nil {
		return false, err
	}
	if pin == nil || pin.PinHash == "" {
		return false, b.refuse(ctx, s, "set your PIN first: choose Set or change PIN.", nil)
	}
	if pin.LockedUntil != nil && time.Now().Before(*pin.LockedUntil) {
		return false, b.refuse(ctx, s, "your PIN is locked after too many wrong tries. Try again later.", nil)
	}
	if !ussd.CheckPIN(pin.PinHash, entered) {
		attempts, failErr := b.d.Pins.RecordFailure(
			ctx,
			pin.GetID(),
			ussdMaxPinAttempts,
			time.Now().Add(ussdPinLockout),
		)
		if failErr != nil {
			return false, failErr
		}
		reason := "the PIN you entered was wrong. Your request was not sent."
		if attempts >= ussdMaxPinAttempts {
			reason = "your PIN is locked after too many wrong tries. Try again in an hour."
		}
		return false, b.refuse(ctx, s, reason, nil)
	}
	return true, b.d.Pins.ClearFailures(ctx, pin.GetID())
}

// --- Borrowing and repaying -------------------------------------------------

func (b *ussdBusiness) borrow(ctx context.Context, s UssdSession, client *fieldv1.ClientObject) error {
	ok, err := b.checkPIN(ctx, s)
	if err != nil || !ok {
		return err
	}
	amount, err := wholeUnits(s.Data[ussd.KeyAmount], b.d.Currency)
	if err != nil {
		return b.refuse(ctx, s, "the amount you entered was not valid. Your request was not sent.", nil)
	}
	_, err = b.d.LoanRequests.RequestLoan(ctx, RequestLoanInput{
		ClientID:       client.GetId(),
		ProductID:      b.d.ProductID,
		Amount:         amount,
		CurrencyCode:   b.d.Currency,
		Purpose:        "ussd",
		IdempotencyKey: "ussd:" + s.ID,
		ActorID:        s.ProfileID,
		ActorType:      ussdActorType,
	})
	if err != nil {
		// A decision (over the limit, not active, an open loan) is told to
		// the borrower; anything else is retried.
		if reason, decided := borrowRefusal(err); decided {
			return b.refuse(ctx, s, reason, nil)
		}
		return fmt.Errorf("ussd loan request: %w", err)
	}
	return nil
}

func (b *ussdBusiness) repay(ctx context.Context, s UssdSession, client *fieldv1.ClientObject) error {
	loan, balance, next, err := b.currentLoan(ctx, client.GetId())
	if errors.Is(err, errUssdNoLoan) {
		return b.refuse(ctx, s, "you have no loan to repay.", nil)
	}
	if err != nil {
		return err
	}

	var amount *commonv1.Money
	switch s.Data[ussd.KeyPayOption] {
	case ussd.PayNextInstalment:
		amount = next.GetOutstanding()
	case ussd.PayFullBalance:
		amount = balance.GetTotalOutstanding()
	case ussd.PayOther:
		minor, parseErr := wholeUnits(s.Data[ussd.KeyPayAmount], b.d.Currency)
		if parseErr != nil {
			return b.refuse(ctx, s, "the amount you entered was not valid. No payment was requested.", nil)
		}
		amount = moneyx.FromMinorUnitsByCurrency(b.d.Currency, minor)
	default:
		return nil
	}
	if amount == nil || (amount.GetUnits() <= 0 && amount.GetNanos() <= 0) {
		return b.refuse(ctx, s, "there is nothing due to pay right now.", nil)
	}

	// The prompt goes to the contact the borrower dialled from: they approve
	// it on that phone with their mobile money PIN.
	_, err = b.d.Loans.InitiateCollection(ctx, &loansv1.InitiateCollectionRequest{
		LoanAccountId:    loan.GetId(),
		ContactId:        s.ContactID,
		CollectionAmount: amount,
		IdempotencyKey:   "ussd:" + s.ID,
	})
	if err != nil {
		return b.refuse(ctx, s, "we could not start the payment. Please try again later.", err)
	}
	return nil
}

// currentLoan is the borrower's seed loan that takes repayments, with its
// balance and next unpaid instalment.
func (b *ussdBusiness) currentLoan(
	ctx context.Context,
	clientID string,
) (*loansv1.LoanAccountObject, *loansv1.LoanBalanceObject, *loansv1.ScheduleEntryObject, error) {
	loan, err := b.repayableLoan(ctx, clientID)
	if err != nil {
		return nil, nil, nil, err
	}
	bal, err := b.d.Loans.LoanBalanceGet(ctx, &loansv1.LoanBalanceGetRequest{LoanAccountId: loan.GetId()})
	if err != nil {
		return nil, nil, nil, fmt.Errorf("loan balance: %w", err)
	}
	sched, err := b.d.Loans.RepaymentScheduleGet(ctx, &loansv1.RepaymentScheduleGetRequest{LoanAccountId: loan.GetId()})
	if err != nil {
		return nil, nil, nil, fmt.Errorf("loan schedule: %w", err)
	}
	return loan, bal.GetData(), nextInstalment(sched.GetData().GetEntries()), nil
}

// repayableLoan finds the borrower's seed loan that takes repayments.
func (b *ussdBusiness) repayableLoan(ctx context.Context, clientID string) (*loansv1.LoanAccountObject, error) {
	stream, err := b.d.Loans.LoanAccountSearch(ctx, &loansv1.LoanAccountSearchRequest{ClientId: clientID})
	if err != nil {
		return nil, fmt.Errorf("find borrower loans: %w", err)
	}
	defer func() { _ = stream.Close() }()
	var loan *loansv1.LoanAccountObject
	for {
		msg, recvErr := stream.Receive()
		if errors.Is(recvErr, io.EOF) {
			break
		}
		if recvErr != nil {
			return nil, fmt.Errorf("find borrower loans: %w", recvErr)
		}
		for _, l := range msg.GetData() {
			if l.GetProductId() == b.d.ProductID && takesRepayment(l.GetStatus()) {
				loan = l
			}
		}
	}
	if loan == nil {
		return nil, errUssdNoLoan
	}
	return loan, nil
}

// nextInstalment is the earliest instalment not yet paid or waived.
func nextInstalment(entries []*loansv1.ScheduleEntryObject) *loansv1.ScheduleEntryObject {
	var next *loansv1.ScheduleEntryObject
	for _, e := range entries {
		if e.GetStatus() == loansv1.ScheduleEntryStatus_SCHEDULE_ENTRY_STATUS_PAID ||
			e.GetStatus() == loansv1.ScheduleEntryStatus_SCHEDULE_ENTRY_STATUS_WAIVED {
			continue
		}
		if next == nil || e.GetInstallmentNumber() < next.GetInstallmentNumber() {
			next = e
		}
	}
	return next
}

// repayableStatuses are the loan states that take a repayment.
var repayableStatuses = []loansv1.LoanStatus{ //nolint:gochecknoglobals // fixed set
	loansv1.LoanStatus_LOAN_STATUS_ACTIVE, loansv1.LoanStatus_LOAN_STATUS_DELINQUENT,
	loansv1.LoanStatus_LOAN_STATUS_DEFAULT, loansv1.LoanStatus_LOAN_STATUS_RESTRUCTURED,
}

func takesRepayment(status loansv1.LoanStatus) bool {
	return slices.Contains(repayableStatuses, status)
}

// --- What the menu shows ----------------------------------------------------

func (b *ussdBusiness) State(ctx context.Context, profileID string) (map[string][]map[string]any, error) {
	rows := map[string][]map[string]any{ussd.RowClient: {}, ussd.RowLoan: {}, ussd.RowBorrow: {}}
	client, err := b.clientFor(ctx, profileID)
	if errors.Is(err, errUssdUnknownBorrower) {
		return rows, nil
	}
	if err != nil {
		return nil, err
	}
	if err = b.borrowerRows(b.actFor(ctx, client), client, profileID, rows); err != nil {
		return nil, err
	}
	return rows, nil
}

func (b *ussdBusiness) borrowerRows(
	ctx context.Context,
	client *fieldv1.ClientObject,
	profileID string,
	rows map[string][]map[string]any,
) error {
	rows[ussd.RowClient] = []map[string]any{{"client": client.GetId()}}

	loan, balance, next, err := b.currentLoan(ctx, client.GetId())
	switch {
	case errors.Is(err, errUssdNoLoan):
	case err != nil:
		return err
	default:
		row := map[string]any{
			"loan_ref": shortRef(loan.GetId()),
			"balance":  formatMoney(balance.GetTotalOutstanding()),
		}
		if next != nil {
			row["next_due"] = formatMoney(next.GetOutstanding())
			row["next_date"] = next.GetDueDate()
		}
		rows[ussd.RowLoan] = []map[string]any{row}
	}

	// Borrowing needs an active client with a PIN, no loan running, and room
	// on the credit profile.
	if loan != nil || client.GetState() != commonv1.STATE_ACTIVE {
		return nil
	}
	pin, err := b.d.Pins.GetByProfile(ctx, profileID)
	if err != nil {
		return err
	}
	if pin == nil || pin.PinHash == "" {
		return nil
	}
	profile, err := b.d.Credit.GetProfile(ctx, client.GetId(), b.d.Currency)
	if err != nil || profile == nil ||
		profile.Status != int32(models.CreditProfileStatusActive) || profile.MaxLoanAmount <= 0 {
		return nil //nolint:nilerr // no usable credit profile simply means no borrow option
	}
	rows[ussd.RowBorrow] = []map[string]any{{
		"limit": formatMoney(moneyx.FromMinorUnitsByCurrency(b.d.Currency, profile.MaxLoanAmount)),
	}}
	return nil
}

// --- helpers ----------------------------------------------------------------

// borrowRefusal is the borrower-facing reason for a decided refusal of a
// loan request; anything else is a failure to retry.
func borrowRefusal(err error) (string, bool) {
	switch {
	case errors.Is(err, ErrAmountExceedsLimit):
		return "you asked for more than you can borrow now. Your request was not sent.", true
	case errors.Is(err, ErrLoanAlreadyOutstanding):
		return "you already have a loan running. Repay it to borrow again.", true
	case errors.Is(err, ErrClientNotKYCVerified):
		return "your registration is not complete. Your agent can help.", true
	case errors.Is(err, ErrProfileSuspended):
		return "borrowing is paused on your account. Your agent can help.", true
	case errors.Is(err, ErrNoPayoutDestination):
		return "we have no verified mobile number to send the loan to. Your agent can help.", true
	default:
		return "", false
	}
}

// refuse texts the borrower why their request was not carried out. cause,
// when given, is logged; the session is not retried.
func (b *ussdBusiness) refuse(ctx context.Context, s UssdSession, reason string, cause error) error {
	logger := util.Log(ctx).WithField("session", s.ID).WithField("reason", reason)
	if cause != nil {
		logger = logger.WithError(cause)
	}
	logger.Info("ussd request refused")
	b.d.Notifier.SendOrLog(ctx, notify.Message{
		Template:  messages.UssdRequestFailed,
		Kind:      ussdNotifyKind,
		Recipient: notify.ToContact(s.ContactID),
		Vars: map[string]any{
			messages.VarLenderName: b.d.LenderName,
			messages.VarReason:     reason,
		},
	})
	return nil
}

// wholeUnits reads an amount typed in whole currency units as minor units.
func wholeUnits(typed, currency string) (int64, error) {
	n, err := strconv.ParseInt(strings.TrimSpace(typed), 10, 64)
	if err != nil || n <= 0 {
		return 0, errors.New("ussd: amount is not a positive whole number")
	}
	scale := int64(1)
	for range moneyx.Decimals(currency) {
		scale *= 10
	}
	return n * scale, nil
}

func formatMoney(m *commonv1.Money) string {
	if m == nil {
		return ""
	}
	currency := m.GetCurrencyCode()
	return currency + " " + messages.FormatAmount(currency, moneyx.ToSmallestUnit(m, moneyx.Decimals(currency)))
}

// shortRefLen is how much of a loan id the borrower is shown.
const shortRefLen = 6

func shortRef(id string) string {
	if len(id) > shortRefLen {
		return strings.ToUpper(id[len(id)-shortRefLen:])
	}
	return strings.ToUpper(id)
}
