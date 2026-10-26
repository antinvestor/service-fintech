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
	"strings"

	"buf.build/gen/go/antinvestor/field/connectrpc/go/v2/field/v1/fieldv1connect"
	fieldv1 "buf.build/gen/go/antinvestor/field/protocolbuffers/go/field/v1"
	"buf.build/gen/go/antinvestor/operations/connectrpc/go/v2/operations/v1/operationsv1connect"
	operationsv1 "buf.build/gen/go/antinvestor/operations/protocolbuffers/go/operations/v1"
	"github.com/pitabwire/frame/v3/data"
	"github.com/pitabwire/util"
	moneyx "github.com/pitabwire/util/moneyx"

	"github.com/antinvestor/service-fintech/apps/loans/service/models"
	"github.com/antinvestor/service-fintech/apps/loans/service/repository"
	"github.com/antinvestor/service-fintech/pkg/constants"
	"github.com/antinvestor/service-fintech/pkg/transferorder"
)

// basisPointsWhole is 100% in basis points.
const basisPointsWhole = 10_000

// TeamResolver names the field team that serves a client.
type TeamResolver interface {
	ServingTeam(ctx context.Context, clientID string) (string, error)
}

type fieldTeamResolver struct {
	fieldCli fieldv1connect.FieldServiceClient
}

// NewFieldTeamResolver reads the serving team from the client's owning team.
func NewFieldTeamResolver(fieldCli fieldv1connect.FieldServiceClient) TeamResolver {
	return &fieldTeamResolver{fieldCli: fieldCli}
}

func (r *fieldTeamResolver) ServingTeam(ctx context.Context, clientID string) (string, error) {
	resp, err := r.fieldCli.ClientGet(ctx, &fieldv1.ClientGetRequest{Id: clientID})
	if err != nil {
		return "", fmt.Errorf("load client %s: %w", clientID, err)
	}
	return strings.TrimSpace(resp.GetData().GetOwningTeamId()), nil
}

// AgentCommission credits the team serving a borrower with its product's
// commission on the interest each repayment paid. The commission is the
// product's cost, owed to the team until it is paid out; the borrower pays
// nothing more. It is posted once per repayment, keyed on it.
type AgentCommission struct {
	products   repository.LoanProductRepository
	teams      TeamResolver
	operations operationsv1connect.OperationsServiceClient
	balances   *TeamCommissions
}

// NewAgentCommission wires the commission step.
func NewAgentCommission(
	products repository.LoanProductRepository,
	teams TeamResolver,
	operations operationsv1connect.OperationsServiceClient,
	balances *TeamCommissions,
) *AgentCommission {
	return &AgentCommission{products: products, teams: teams, operations: operations, balances: balances}
}

// Post credits the commission on one repayment. Nothing is owed on a
// recovery, on a repayment without interest, on a product without a
// commission rate, or for a client no team serves.
func (c *AgentCommission) Post(ctx context.Context, la *models.LoanAccount, r *models.Repayment) error {
	if c == nil || r.InterestApplied <= 0 || IsRecovery(r) {
		return nil
	}
	product, err := c.products.GetByID(ctx, la.ProductID)
	if err != nil {
		return fmt.Errorf("load product %s for commission: %w", la.ProductID, err)
	}
	amount := r.InterestApplied * product.AgentCommissionPercent / basisPointsWhole
	if amount <= 0 {
		return nil
	}
	team, err := c.teams.ServingTeam(ctx, la.ClientID)
	if err != nil {
		return c.retryUnlessRefused(ctx, la, err)
	}
	if team == "" {
		util.Log(ctx).WithField("loan_id", la.GetID()).Warn("no team serves the client; no commission is owed")
		return nil
	}
	if c.operations == nil {
		return ErrOperationsClientUnavailable
	}
	reference := "commission:" + r.GetID()
	extra := data.JSONMap{
		fieldLoanID:    la.GetID(),
		fieldClientID:  la.ClientID,
		"team_id":      team,
		"repayment_id": r.GetID(),
	}
	_, err = c.operations.TransferOrderExecute(ctx, &operationsv1.TransferOrderExecuteRequest{
		Data: transferorder.Typed(&operationsv1.TransferOrderObject{
			DebitAccountRef:  constants.ProductCommissionExpenseAccount(la.ProductID),
			CreditAccountRef: constants.TeamCommissionPayableAccount(team),
			Amount:           moneyx.FromMinorUnitsByCurrency(r.CurrencyCode, amount),
			Reference:        reference,
			Description:      "Serving team's commission on repaid interest",
			ExtraData:        extra.ToProtoStruct(),
		}, constants.TransferTypeAgentCommission),
	})
	if err != nil {
		return c.retryUnlessRefused(ctx, la, fmt.Errorf("post commission for repayment %s: %w", r.GetID(), err))
	}
	// The team's balance follows the ledger: a failure here is retried with
	// the settlement, and the posting above is idempotent on its reference.
	return c.balances.Accrue(ctx, la, team, r.CurrencyCode, amount, reference)
}

// retryUnlessRefused keeps a transient failure for the settlement to retry,
// and drops a permanent refusal with an error log: nothing moved, and a
// commission that can never post must not hold back the funders' share.
func (c *AgentCommission) retryUnlessRefused(ctx context.Context, la *models.LoanAccount, err error) error {
	if !permanentFundingRefusal(err) {
		return err
	}
	util.Log(ctx).WithError(err).WithField("loan_id", la.GetID()).
		Error("commission refused; recorded and not retried")
	return nil
}
