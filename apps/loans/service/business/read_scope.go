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
	"slices"
	"strings"

	"buf.build/gen/go/antinvestor/field/connectrpc/go/field/v1/fieldv1connect"
	fieldv1 "buf.build/gen/go/antinvestor/field/protocolbuffers/go/field/v1"
	"connectrpc.com/connect"
	"github.com/pitabwire/frame/v2/security"
	"github.com/pitabwire/util"

	"github.com/antinvestor/service-fintech/apps/loans/service/repository"
)

// ErrNoClientForProfile is returned by a ClientResolver when the identity
// platform holds no client row for the caller's profile.
var ErrNoClientForProfile = errors.New("loans: no client is linked to the profile")

// ClientResolver maps an authenticated profile onto the client the loans
// service lends to. Tokens carry a profile id; loans are owned by client id,
// so a borrower's reads have to be bridged through this lookup.
type ClientResolver interface {
	ResolveByProfileID(ctx context.Context, profileID string) (clientID string, err error)
}

// defaultStaffRoles are the tenancy platform roles identity assigns to
// workforce members. Anyone holding one of them (or the internal-system role)
// reads partition-wide under loan_view; every other caller is a client and is
// scoped to the loans it owns.
//
//nolint:gochecknoglobals // immutable default, overridable through NewReadScope
var defaultStaffRoles = []string{"admin", "operator", "viewer"}

// ReadScope decides, per request, whether the caller may read a record owned
// by a given client. Staff and internal-system callers may read any loan in
// the partition; clients may read only their own.
type ReadScope struct {
	resolver   ClientResolver
	staffRoles []string
}

// NewReadScope builds a scope. staffRoles overrides the default platform role
// list; a nil resolver makes every client-scoped read fail closed, which is
// the safe behaviour for a binary that has not wired the identity client yet.
func NewReadScope(resolver ClientResolver, staffRoles ...string) *ReadScope {
	roles := defaultStaffRoles
	if len(staffRoles) > 0 {
		roles = staffRoles
	}
	return &ReadScope{resolver: resolver, staffRoles: roles}
}

// callerClient classifies the caller. It returns staff=true for callers with
// partition-wide access, otherwise the client id the caller owns.
func (s *ReadScope) callerClient(ctx context.Context) (string, bool, error) {
	claims := security.ClaimsFromContext(ctx)
	if claims == nil {
		// No claims means the call did not come through the authenticated
		// RPC surface (scheduled jobs, in-process callers). Those are trusted.
		return "", true, nil
	}
	if claims.IsInternalSystem() {
		return "", true, nil
	}
	for _, role := range claims.GetRoles() {
		if slices.ContainsFunc(s.staffRoles, func(r string) bool { return strings.EqualFold(r, role) }) {
			return "", true, nil
		}
	}

	if s.resolver == nil {
		util.Log(ctx).WithField("profile_id", claims.GetProfileID()).
			Error("client-scoped read refused: no client resolver is configured")
		return "", false, ErrReadScopeUnavailable
	}

	clientID, err := s.resolver.ResolveByProfileID(ctx, claims.GetProfileID())
	if err != nil {
		if errors.Is(err, ErrNoClientForProfile) {
			return "", false, ErrLoanNotOwned
		}
		return "", false, fmt.Errorf("resolve caller client: %w", err)
	}
	return clientID, false, nil
}

// AuthorizeClient returns nil when the caller may read a record owned by
// ownerClientID, and ErrLoanNotOwned when a client caller asks for somebody
// else's record.
func (s *ReadScope) AuthorizeClient(ctx context.Context, ownerClientID string) error {
	clientID, staff, err := s.callerClient(ctx)
	if err != nil {
		return err
	}
	if staff {
		return nil
	}
	if clientID == "" || clientID != ownerClientID {
		util.Log(ctx).
			WithField("caller_client_id", clientID).
			WithField("owner_client_id", ownerClientID).
			Warn("client attempted to read a loan record it does not own")
		return ErrLoanNotOwned
	}
	return nil
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

// fieldClientResolver bridges a profile to its client row on the field
// service, which the identity binary serves alongside its own API.
type fieldClientResolver struct {
	fieldCli fieldv1connect.FieldServiceClient
}

// NewFieldClientResolver builds the production client resolver.
func NewFieldClientResolver(fieldCli fieldv1connect.FieldServiceClient) ClientResolver {
	return &fieldClientResolver{fieldCli: fieldCli}
}

// ResolveByProfileID searches clients by free text. The clients search vector
// includes profile_id, so the profile id is a usable query term; results are
// still filtered on an exact profile match because a free-text index can
// return neighbours.
func (r *fieldClientResolver) ResolveByProfileID(ctx context.Context, profileID string) (string, error) {
	profileID = strings.TrimSpace(profileID)
	if profileID == "" {
		return "", ErrNoClientForProfile
	}

	stream, err := r.fieldCli.ClientSearch(ctx, connect.NewRequest(
		&fieldv1.ClientSearchRequest{Query: profileID},
	))
	if err != nil {
		return "", fmt.Errorf("client search: %w", err)
	}
	defer func() { _ = stream.Close() }()

	for stream.Receive() {
		for _, client := range stream.Msg().GetData() {
			if client.GetProfileId() == profileID {
				return client.GetId(), nil
			}
		}
	}
	if streamErr := stream.Err(); streamErr != nil {
		return "", fmt.Errorf("client search: %w", streamErr)
	}
	return "", ErrNoClientForProfile
}
