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

package clients

import (
	"context"
	"fmt"

	"buf.build/gen/go/antinvestor/field/connectrpc/go/field/v1/fieldv1connect"
	"buf.build/gen/go/antinvestor/files/connectrpc/go/files/v1/filesv1connect"
	"buf.build/gen/go/antinvestor/identity/connectrpc/go/identity/v1/identityv1connect"
	"buf.build/gen/go/antinvestor/ledger/connectrpc/go/v1/ledgerv1connect"
	"buf.build/gen/go/antinvestor/loans/connectrpc/go/loans/v1/loansv1connect"
	"buf.build/gen/go/antinvestor/notification/connectrpc/go/notification/v1/notificationv1connect"
	"buf.build/gen/go/antinvestor/payment/connectrpc/go/v1/paymentv1connect"
	"buf.build/gen/go/antinvestor/profile/connectrpc/go/profile/v1/profilev1connect"
	"buf.build/gen/go/antinvestor/savings/connectrpc/go/savings/v1/savingsv1connect"
	"buf.build/gen/go/antinvestor/tenancy/connectrpc/go/tenancy/v1/tenancyv1connect"
	"connectrpc.com/connect"
	"github.com/antinvestor/common/v2"
	"github.com/antinvestor/common/v2/connection"
	"github.com/antinvestor/common/v2/servicecatalog"
	"github.com/pitabwire/util"
)

// ServiceEndpoints holds the URI for every platform service.
// If an endpoint is empty, its client is skipped during initialisation.
type ServiceEndpoints struct {
	IdentityURI     string
	LoanMgmtURI     string
	SavingsURI      string
	LedgerURI       string
	PaymentURI      string
	NotificationURI string
	FilesURI        string
	ProfileURI      string
	PartitionURI    string
}

// PlatformClients holds all external service client connections.
type PlatformClients struct {
	LenderIdentity     fieldv1connect.FieldServiceClient
	LenderRegistry     identityv1connect.IdentityServiceClient
	LenderLoanMgmt     loansv1connect.LoanManagementServiceClient
	LenderSavings      savingsv1connect.SavingsServiceClient
	LedgerClient       ledgerv1connect.LedgerServiceClient
	PaymentClient      paymentv1connect.PaymentServiceClient
	NotificationClient notificationv1connect.NotificationServiceClient
	FilesClient        filesv1connect.FilesServiceClient
	ProfileClient      profilev1connect.ProfileServiceClient
	TenancyClient      tenancyv1connect.TenancyServiceClient
}

// audienceToServiceID maps legacy service audience labels to catalog IDs.
func audienceToServiceID(audience string) servicecatalog.ServiceID {
	switch audience {
	case "service_identity":
		return servicecatalog.ServiceIdentity
	case "service_fintech_loans", "service_loans":
		return servicecatalog.ServiceLoans
	case "service_savings":
		return servicecatalog.ServiceSavings
	case "service_ledger":
		return servicecatalog.ServiceLedger
	case "service_payment":
		return servicecatalog.ServicePayment
	case "service_notification":
		return servicecatalog.ServiceNotification
	case "service_file", "service_files":
		return servicecatalog.ServiceFiles
	case "service_profile":
		return servicecatalog.ServiceProfile
	case "service_tenancy", "service_partition":
		return servicecatalog.ServiceTenancy
	case "service_limits":
		return servicecatalog.ServiceLimits
	case "service_funding":
		return servicecatalog.ServiceFunding
	case "service_operations":
		return servicecatalog.ServiceOperations
	case "service_trustage":
		return servicecatalog.ServiceTrustage
	default:
		return servicecatalog.ServiceID(audience)
	}
}

// newClient creates one typed Connect RPC client for the given endpoint and audience.
func newClient[T any](
	ctx context.Context, cfg any, endpoint, audience string,
	ctor func(connect.HTTPClient, string, ...connect.ClientOption) T,
) (T, error) {
	target := common.ServiceTarget{
		Endpoint:  endpoint,
		ServiceID: audienceToServiceID(audience),
	}
	return connection.NewServiceClient(ctx, cfg, target, ctor)
}

// NewPlatformClients creates all platform service clients using the given
// endpoints. cfg is passed through to connection.NewServiceClient for auth
// resolution. Clients whose endpoint is empty are left nil with a warning.
func NewPlatformClients(ctx context.Context, cfg any, ep ServiceEndpoints) (*PlatformClients, error) {
	pc := &PlatformClients{}
	var firstErr error
	b := &clientBuilder{ctx: ctx, cfg: cfg, log: util.Log(ctx)}

	initServiceClient(b, ep.IdentityURI, "service_identity", "fintech-identity",
		func(c fieldv1connect.FieldServiceClient) { pc.LenderIdentity = c }, fieldv1connect.NewFieldServiceClient)
	initServiceClient(
		b,
		ep.IdentityURI,
		"service_identity",
		"lender-registry",
		func(c identityv1connect.IdentityServiceClient) { pc.LenderRegistry = c },
		identityv1connect.NewIdentityServiceClient,
	)
	initServiceClient(
		b,
		ep.LoanMgmtURI,
		"service_fintech_loans",
		"lender-loan-management",
		func(c loansv1connect.LoanManagementServiceClient) { pc.LenderLoanMgmt = c },
		loansv1connect.NewLoanManagementServiceClient,
	)
	initServiceClient(
		b,
		ep.SavingsURI,
		"service_savings",
		"lender-savings",
		func(c savingsv1connect.SavingsServiceClient) { pc.LenderSavings = c },
		savingsv1connect.NewSavingsServiceClient,
	)
	initServiceClient(b, ep.LedgerURI, "service_ledger", "ledger",
		func(c ledgerv1connect.LedgerServiceClient) { pc.LedgerClient = c }, ledgerv1connect.NewLedgerServiceClient)
	initServiceClient(
		b,
		ep.PaymentURI,
		"service_payment",
		"payment",
		func(c paymentv1connect.PaymentServiceClient) { pc.PaymentClient = c },
		paymentv1connect.NewPaymentServiceClient,
	)
	initServiceClient(
		b,
		ep.NotificationURI,
		"service_notification",
		"notification",
		func(c notificationv1connect.NotificationServiceClient) { pc.NotificationClient = c },
		notificationv1connect.NewNotificationServiceClient,
	)
	initServiceClient(b, ep.FilesURI, "service_file", "files",
		func(c filesv1connect.FilesServiceClient) { pc.FilesClient = c }, filesv1connect.NewFilesServiceClient)
	initServiceClient(
		b,
		ep.ProfileURI,
		"service_profile",
		"profile",
		func(c profilev1connect.ProfileServiceClient) { pc.ProfileClient = c },
		profilev1connect.NewProfileServiceClient,
	)
	initServiceClient(
		b,
		ep.PartitionURI,
		"service_tenancy",
		"partition",
		func(c tenancyv1connect.TenancyServiceClient) { pc.TenancyClient = c },
		tenancyv1connect.NewTenancyServiceClient,
	)

	firstErr = b.firstErr
	return pc, firstErr
}

// clientBuilder accumulates the first error while initialising multiple service clients.
type clientBuilder struct {
	ctx      context.Context
	cfg      any
	log      *util.LogEntry
	firstErr error
}

// initServiceClient creates a single service client and assigns it via the setter.
// Skips clients whose endpoint is empty; records the first error on the builder.
func initServiceClient[T any](
	b *clientBuilder,
	endpoint, audience, name string,
	setter func(T),
	ctor func(connect.HTTPClient, string, ...connect.ClientOption) T,
) {
	if endpoint == "" {
		b.log.Warn(fmt.Sprintf("Skipping %s client: no endpoint configured", name))
		return
	}
	cli, err := newClient(b.ctx, b.cfg, endpoint, audience, ctor)
	if err != nil {
		b.log.WithError(err).Warn(fmt.Sprintf("Could not setup %s client", name))
		if b.firstErr == nil {
			b.firstErr = err
		}
		return
	}
	setter(cli)
}
