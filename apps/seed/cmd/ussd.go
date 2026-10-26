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

package main

import (
	"context"
	"errors"

	"buf.build/gen/go/antinvestor/field/connectrpc/go/v2/field/v1/fieldv1connect"
	"buf.build/gen/go/antinvestor/loans/connectrpc/go/v2/loans/v1/loansv1connect"
	"buf.build/gen/go/antinvestor/notification/connectrpc/go/v2/notification/v1/notificationv1connect"
	"buf.build/gen/go/antinvestor/profile/connectrpc/go/v2/profile/v1/profilev1connect"
	"github.com/antinvestor/common/v3"
	"github.com/antinvestor/common/v3/connection"
	"github.com/antinvestor/common/v3/servicecatalog"
	"github.com/pitabwire/frame/v3"
	"github.com/pitabwire/frame/v3/datastore/pool"
	"github.com/pitabwire/util"

	aconfig "github.com/antinvestor/service-fintech/apps/seed/config"
	"github.com/antinvestor/service-fintech/apps/seed/service/business"
	"github.com/antinvestor/service-fintech/apps/seed/service/repository"
	"github.com/antinvestor/service-fintech/apps/seed/service/ussd"
	"github.com/antinvestor/service-fintech/pkg/messages"
	"github.com/antinvestor/service-fintech/pkg/notify"
)

// ussdEnabled reports whether borrower USSD is configured.
func ussdEnabled(cfg *aconfig.SeedConfig) bool { return cfg.UssdSecretKey != "" }

// installUssdMenu registers the borrower menu and gateway settings with the
// USSD engine. Setup Job only.
func installUssdMenu(ctx context.Context, svc *frame.Service, cfg *aconfig.SeedConfig) error {
	if !ussdEnabled(cfg) {
		return nil
	}
	opener, err := ussd.NewOpener(cfg.UssdSecretKey)
	if err != nil {
		return err
	}
	client := ussd.NewClient(cfg.UssdServiceURI, svc.HTTPClientManager().Client(ctx))
	if client == nil {
		return errors.New("ussd: USSD_SERVICE_URI is required when SEED_USSD_SECRET_KEY is set")
	}
	return ussd.Install(ctx, client, ussd.Settings{
		ServiceID: cfg.UssdServiceID,
		AuthKey:   cfg.UssdGatewayAuthKey,
		PublicKey: opener.PublicKey(),
		StateURL:  cfg.UssdStateURL,
	})
}

// buildUssd wires the borrower USSD business, or returns nil when USSD is
// off. A misconfigured USSD stops the process rather than half-serving.
func buildUssd(
	ctx context.Context,
	cfg *aconfig.SeedConfig,
	dbPool pool.Pool,
	svc *frame.Service,
	loanRequests business.LoanRequestBusiness,
	credit business.CreditProfileBusiness,
	log *util.LogEntry,
) business.UssdBusiness {
	if !ussdEnabled(cfg) {
		return nil
	}
	opener, err := ussd.NewOpener(cfg.UssdSecretKey)
	if err != nil {
		log.WithError(err).Fatal("main -- SEED_USSD_SECRET_KEY is invalid")
	}

	fieldCli, err := connection.NewServiceClient(ctx, cfg, common.ServiceTarget{
		Endpoint: cfg.IdentityServiceURI, ServiceID: servicecatalog.ServiceIdentity,
	}, fieldv1connect.NewFieldServiceClient)
	if err != nil {
		log.WithError(err).Fatal("main -- ussd field client could not be created")
	}
	loansCli, err := connection.NewServiceClient(ctx, cfg, common.ServiceTarget{
		Endpoint: cfg.LoanMgmtServiceURI, ServiceID: servicecatalog.ServiceLoans,
	}, loansv1connect.NewLoanManagementServiceClient)
	if err != nil {
		log.WithError(err).Fatal("main -- ussd loans client could not be created")
	}
	profileCli, err := connection.NewServiceClient(ctx, cfg, common.ServiceTarget{
		Endpoint:              cfg.ProfileServiceURI,
		WorkloadAPITargetPath: cfg.ProfileServiceWorkloadAPITargetPath,
		ServiceID:             servicecatalog.ServiceProfile,
	}, profilev1connect.NewProfileServiceClient)
	if err != nil {
		log.WithError(err).Fatal("main -- ussd profile client could not be created")
	}
	notificationCli, err := connection.NewServiceClient(ctx, cfg, common.ServiceTarget{
		Endpoint:              cfg.NotificationServiceURI,
		WorkloadAPITargetPath: cfg.NotificationServiceWorkloadAPITargetPath,
		ServiceID:             servicecatalog.ServiceNotification,
	}, notificationv1connect.NewNotificationServiceClient)
	if err != nil {
		log.WithError(err).Fatal("main -- ussd notification client could not be created")
	}

	return business.NewUssdBusiness(business.UssdDeps{
		Opener:         opener,
		Pins:           repository.NewUssdPinRepository(ctx, dbPool, svc.WorkManager()),
		Field:          fieldCli,
		Loans:          loansCli,
		Profiles:       profileCli,
		LoanRequests:   loanRequests,
		Credit:         credit,
		Notifier:       notify.New(notificationCli, messages.Registry()),
		ProductID:      cfg.SeedProductID,
		Currency:       cfg.SeedCurrencyCode,
		LenderName:     cfg.LenderName,
		ServiceSubject: cfg.Name(),
	})
}
