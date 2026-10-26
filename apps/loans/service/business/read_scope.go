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
	"fmt"
	"slices"
	"strings"
	"time"

	"buf.build/gen/go/antinvestor/payment/connectrpc/go/v2/v1/paymentv1connect"

	"buf.build/gen/go/antinvestor/field/connectrpc/go/v2/field/v1/fieldv1connect"
	fieldv1 "buf.build/gen/go/antinvestor/field/protocolbuffers/go/field/v1"
	"github.com/hashicorp/golang-lru/v2/expirable"
	"github.com/pitabwire/frame/v3/security"
	"github.com/pitabwire/util"

	"github.com/antinvestor/service-fintech/apps/loans/service/repository"
	"github.com/antinvestor/service-fintech/pkg/audit"
)

// CallerAccess is what the identity platform says a profile may act for:
// the client it is as a borrower and the clients it serves as a field agent.
type CallerAccess struct {
	ClientID        string
	MemberID        string
	ServedClientIDs []string
}

// owns reports whether clientID is the caller's own client.
func (a *CallerAccess) owns(clientID string) bool {
	return a != nil && clientID != "" && a.ClientID == clientID
}

// serves reports whether the caller acts for clientID as a field agent.
func (a *CallerAccess) serves(clientID string) bool {
	return a != nil && clientID != "" && slices.Contains(a.ServedClientIDs, clientID)
}

// clientIDs lists every client the caller may read: its own and the ones it
// serves.
func (a *CallerAccess) clientIDs() []string {
	if a == nil {
		return nil
	}
	out := make([]string, 0, len(a.ServedClientIDs)+1)
	if a.ClientID != "" {
		out = append(out, a.ClientID)
	}
	for _, id := range a.ServedClientIDs {
		if id != "" && id != a.ClientID {
			out = append(out, id)
		}
	}
	return out
}

// AccessResolver maps an authenticated profile onto the clients it may act
// for. Tokens carry a profile id; loans are owned by client id, so every
// non-staff read and write is bridged through this lookup.
type AccessResolver interface {
	ResolveAccess(ctx context.Context, profileID string) (*CallerAccess, error)
}

// defaultStaffRoles are the tenancy platform roles identity assigns to
// back-office workforce members. Anyone holding one of them (or the
// internal-system role) acts partition-wide; every other caller is a
// borrower or a field agent and is scoped through the AccessResolver.
//
//nolint:gochecknoglobals // immutable default, overridable through NewReadScope
var defaultStaffRoles = []string{"admin", "operator", "viewer"}

// ReadScope decides, per request, whether the caller may act on a record
// owned by a given client. Staff and internal-system callers may act on any
// loan in the partition; a borrower only on their own; a field agent only on
// the clients they serve.
type ReadScope struct {
	resolver   AccessResolver
	staffRoles []string
}

// NewReadScope builds a scope. staffRoles overrides the default platform role
// list; a nil resolver makes every non-staff call fail closed, which is the
// safe behaviour for a binary that has not wired the identity client yet.
func NewReadScope(resolver AccessResolver, staffRoles ...string) *ReadScope {
	roles := defaultStaffRoles
	if len(staffRoles) > 0 {
		roles = staffRoles
	}
	return &ReadScope{resolver: resolver, staffRoles: roles}
}

// callerAccess classifies the caller. It returns staff=true for callers with
// partition-wide access, otherwise what the caller may act for.
func (s *ReadScope) callerAccess(ctx context.Context) (*CallerAccess, bool, error) {
	if s == nil {
		// An unconfigured scope behaves like NewReadScope(nil): trusted
		// in-process and staff callers pass, everyone else fails closed.
		s = &ReadScope{staffRoles: defaultStaffRoles}
	}
	claims := security.ClaimsFromContext(ctx)
	if claims == nil {
		// No claims means the call did not come through the authenticated
		// RPC surface (scheduled jobs, in-process callers). Those are trusted.
		return nil, true, nil
	}
	if claims.IsInternalSystem() {
		return nil, true, nil
	}
	for _, role := range claims.GetRoles() {
		if slices.ContainsFunc(s.staffRoles, func(r string) bool { return strings.EqualFold(r, role) }) {
			return nil, true, nil
		}
	}

	if s.resolver == nil {
		util.Log(ctx).WithField("profile_id", claims.GetProfileID()).
			Error("client-scoped call refused: no access resolver is configured")
		return nil, false, ErrReadScopeUnavailable
	}

	profileID := strings.TrimSpace(claims.GetProfileID())
	if profileID == "" {
		return &CallerAccess{}, false, nil
	}
	access, err := s.resolver.ResolveAccess(ctx, profileID)
	if err != nil {
		return nil, false, fmt.Errorf("resolve caller access: %w", err)
	}
	if access == nil {
		access = &CallerAccess{}
	}
	return access, false, nil
}

// IsStaff reports whether the caller is an internal principal or holds a
// configured staff role. It never errs: an unresolvable caller is not staff.
func (s *ReadScope) IsStaff(ctx context.Context) bool {
	_, staff, err := s.callerAccess(ctx)
	return err == nil && staff
}

// AuthorizeClient returns nil when the caller may act on a record owned by
// ownerClientID: staff, the borrower themself, or a field agent serving the
// client. Anyone else gets ErrLoanNotOwned.
func (s *ReadScope) AuthorizeClient(ctx context.Context, ownerClientID string) error {
	access, staff, err := s.callerAccess(ctx)
	if err != nil {
		return err
	}
	if staff || access.owns(ownerClientID) || access.serves(ownerClientID) {
		return nil
	}
	util.Log(ctx).
		WithField("caller_client_id", access.ClientID).
		WithField("caller_member_id", access.MemberID).
		WithField("owner_client_id", ownerClientID).
		Warn("caller attempted to act on a loan record outside its scope")
	return ErrLoanNotOwned
}

// AuthorizeAgent returns nil when the caller may act for ownerClientID on
// the lender's side: staff, or a field agent serving the client. A borrower
// is refused even for their own loan; recording a repayment or starting a
// collection is something done to a borrower, not by one.
func (s *ReadScope) AuthorizeAgent(ctx context.Context, ownerClientID string) error {
	access, staff, err := s.callerAccess(ctx)
	if err != nil {
		return err
	}
	// An agent who is also the borrower must not act on their own loan.
	if staff || (access.serves(ownerClientID) && !access.owns(ownerClientID)) {
		return nil
	}
	util.Log(ctx).
		WithField("caller_client_id", access.ClientID).
		WithField("caller_member_id", access.MemberID).
		WithField("owner_client_id", ownerClientID).
		Warn("caller attempted a lender-side action for a client it does not serve")
	return ErrNotServingClient
}

// ClientFilter returns the client ids a search must be confined to. It
// returns unrestricted=true for staff. A non-staff caller with nothing in
// scope gets a never-matching sentinel so "IN ?" stays valid and empty.
func (s *ReadScope) ClientFilter(ctx context.Context) ([]string, bool, error) {
	access, staff, err := s.callerAccess(ctx)
	if err != nil {
		return nil, false, err
	}
	if staff {
		return nil, true, nil
	}
	ids := access.clientIDs()
	if len(ids) == 0 {
		ids = []string{""}
	}
	return ids, false, nil
}

// ServingMemberID returns the caller's workforce member id when the caller
// is a field agent serving ownerClientID, and "" otherwise.
func (s *ReadScope) ServingMemberID(ctx context.Context, ownerClientID string) string {
	access, staff, err := s.callerAccess(ctx)
	if err != nil || staff || !access.serves(ownerClientID) {
		return ""
	}
	return access.MemberID
}

// IsBorrowerOf reports whether the caller is the borrower who owns
// ownerClientID (and not acting as staff).
func (s *ReadScope) IsBorrowerOf(ctx context.Context, ownerClientID string) bool {
	access, staff, err := s.callerAccess(ctx)
	return err == nil && !staff && access.owns(ownerClientID)
}

// authorizeLoanAccount is the shared check for RPCs that address a loan
// account by id: it loads the account and verifies the caller may read it.
func authorizeLoanAccount(
	ctx context.Context,
	scope *ReadScope,
	loanAccountRepo repository.LoanAccountRepository,
	loanAccountID string,
) error {
	la, err := loanAccountRepo.GetByID(ctx, loanAccountID)
	if err != nil {
		return ErrLoanAccountNotFound
	}
	return scope.AuthorizeClient(ctx, la.ClientID)
}

// Option configures optional collaborators on a business object without
// widening the constructor signatures every binary wires by hand.
type Option func(*options)

type options struct {
	scope             *ReadScope
	disbRepo          repository.DisbursementRepository
	scheduleEntryRepo repository.ScheduleEntryRepository
	scheduleBusiness  RepaymentScheduleBusiness
	notifier          *LoanNotifier
	auditWriter       *audit.Writer
	payoutChecker     PayoutDestinationChecker
	payments          paymentv1connect.PaymentServiceClient
	clientStanding    ClientStandingChecker
	fundingSettlement *FundingSettlement
	repaymentApplier  repository.RepaymentApplier
}

// WithRepaymentApplier supplies the transactional step that makes a posted
// repayment count against the loan.
func WithRepaymentApplier(a repository.RepaymentApplier) Option {
	return func(o *options) { o.repaymentApplier = a }
}

// WithFundingSettlement shares each recorded repayment out to the loan's
// funders as soon as it is recorded.
func WithFundingSettlement(fs *FundingSettlement) Option {
	return func(o *options) { o.fundingSettlement = fs }
}

// WithScheduleEntries supplies the schedule entry repository to flows that
// must check an installment belongs to a loan.
func WithScheduleEntries(repo repository.ScheduleEntryRepository) Option {
	return func(o *options) { o.scheduleEntryRepo = repo }
}

// WithAuditWriter installs the domain audit writer for flows that do not
// take it as a constructor argument.
func WithAuditWriter(w *audit.Writer) Option {
	return func(o *options) { o.auditWriter = w }
}

// WithPayoutDestinationChecker installs the check that a disbursement's
// destination belongs to the borrower.
func WithPayoutDestinationChecker(c PayoutDestinationChecker) Option {
	return func(o *options) { o.payoutChecker = c }
}

// WithPaymentClient installs the payment service, through which a borrower
// is asked to pay. Without it collection prompts are refused.
func WithPaymentClient(c paymentv1connect.PaymentServiceClient) Option {
	return func(o *options) { o.payments = c }
}

// WithNotifier installs the borrower/agent notifier. Without it the business
// flows run silently (local development, tests).
func WithNotifier(n *LoanNotifier) Option {
	return func(o *options) { o.notifier = n }
}

// WithScheduleBusiness lets the disbursement flow re-anchor the repayment
// schedule to the date the money actually left. Without it the schedule
// generated at account creation stands.
func WithScheduleBusiness(sb RepaymentScheduleBusiness) Option {
	return func(o *options) { o.scheduleBusiness = sb }
}

// WithReadScope installs the caller scope used by client-facing reads. When
// it is not supplied the business falls back to NewReadScope(nil), which
// admits staff and refuses client callers.
func WithReadScope(scope *ReadScope) Option {
	return func(o *options) { o.scope = scope }
}

// WithStatementSources supplies the repositories the statement reads
// disbursements and the repayment schedule from. When absent they are
// derived from the loan account repository's pool.
func WithStatementSources(
	disbRepo repository.DisbursementRepository,
	scheduleEntryRepo repository.ScheduleEntryRepository,
) Option {
	return func(o *options) {
		o.disbRepo = disbRepo
		o.scheduleEntryRepo = scheduleEntryRepo
	}
}

func applyOptions(opts []Option) options {
	var o options
	for _, opt := range opts {
		opt(&o)
	}
	if o.scope == nil {
		o.scope = NewReadScope(nil)
	}
	return o
}

// Access scopes are cached briefly: one request checks scope several times
// (authorise, sanitise, stamp the agent), and an agent's portfolio changes
// on the scale of days. A reassignment takes effect within the TTL.
const (
	accessCacheSize = 4096
	accessCacheTTL  = 30 * time.Second
)

// fieldAccessResolver asks the field service, which the identity binary
// serves alongside its own API, what a profile may act for.
type fieldAccessResolver struct {
	fieldCli fieldv1connect.FieldServiceClient
	cache    *expirable.LRU[string, *CallerAccess]
}

// NewFieldAccessResolver builds the production access resolver.
func NewFieldAccessResolver(fieldCli fieldv1connect.FieldServiceClient) AccessResolver {
	return &fieldAccessResolver{
		fieldCli: fieldCli,
		cache:    expirable.NewLRU[string, *CallerAccess](accessCacheSize, nil, accessCacheTTL),
	}
}

// ResolveAccess calls ClientAccessScope as the loans service, naming the end
// user it is serving. Results are cached per tenancy and profile.
func (r *fieldAccessResolver) ResolveAccess(ctx context.Context, profileID string) (*CallerAccess, error) {
	key := profileID
	if claims := security.ClaimsFromContext(ctx); claims != nil {
		key = claims.GetTenantID() + "|" + claims.GetPartitionID() + "|" + profileID
	}
	if hit, ok := r.cache.Get(key); ok {
		return hit, nil
	}
	resp, err := r.fieldCli.ClientAccessScope(ctx, &fieldv1.ClientAccessScopeRequest{ProfileId: profileID})
	if err != nil {
		return nil, fmt.Errorf("client access scope: %w", err)
	}
	access := &CallerAccess{
		ClientID:        resp.GetClientId(),
		MemberID:        resp.GetMemberId(),
		ServedClientIDs: resp.GetServedClientIds(),
	}
	r.cache.Add(key, access)
	return access, nil
}
