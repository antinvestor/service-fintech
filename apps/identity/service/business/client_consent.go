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
	"strings"
	"time"

	commonv1 "buf.build/gen/go/antinvestor/common/protocolbuffers/go/common/v1"
	fieldv1 "buf.build/gen/go/antinvestor/field/protocolbuffers/go/field/v1"
	profilev1 "buf.build/gen/go/antinvestor/profile/protocolbuffers/go/profile/v1"
	"github.com/pitabwire/frame/v3/data"
	"github.com/pitabwire/util"

	"github.com/antinvestor/service-fintech/apps/identity/service/models"
)

// Consent handshake carried in client properties. Registration never asks
// for consent: a field agent's client starts CREATED. Activating it (a save
// that moves it to ACTIVE) once its KYC is fully verified sends a code to
// the person's mobile contact and answers with consent_verification_id and
// consent_status "pending"; the agent resubmits the activation with that id
// and the code the person received. The check also verifies the contact on
// the profile, so a newly registered person's phone is proven theirs.
const (
	consentVerificationIDKey = "consent_verification_id"
	consentCodeKey           = "consent_code"
	consentStatusKey         = "consent_status"
	consentStatusPending     = "pending"
	consentCodeTTL           = 15 * time.Minute
	consentMaxAttempts       = 5
)

type consentProperties struct {
	verificationID string
	code           string
}

// takeConsentProperties removes the handshake keys from props: they are
// never stored on the client.
func takeConsentProperties(props map[string]any) consentProperties {
	c := consentProperties{
		verificationID: strings.TrimSpace(stringValue(props[consentVerificationIDKey])),
		code:           strings.TrimSpace(stringValue(props[consentCodeKey])),
	}
	delete(props, consentVerificationIDKey)
	delete(props, consentCodeKey)
	delete(props, consentStatusKey)
	return c
}

// confirmActivation gates a field agent activating a client. It returns a
// pending response when a code has just been sent, nil when the person
// consented, and an error when the code is wrong, spent or expired, or the
// person has no contact to send it to.
func (b *clientBusiness) confirmActivation(
	ctx context.Context,
	client *models.Client,
	scope *callerScope,
	consent consentProperties,
) (*fieldv1.ClientObject, error) {
	if b.consentRepo == nil || b.profiles == nil {
		return nil, ErrClientProfileUnavailable
	}
	now := time.Now().UTC()
	if consent.verificationID == "" {
		return b.startConsent(ctx, client, scope, now)
	}

	challenge, err := b.consentRepo.GetByID(ctx, consent.verificationID)
	if err != nil || challenge.ProfileID != client.ProfileID || challenge.MemberID != scope.member.GetID() ||
		consent.code == "" {
		return nil, ErrClientConsentFailed
	}
	allowed, err := b.consentRepo.TakeAttempt(ctx, challenge.GetID(), consentMaxAttempts, now)
	if err != nil || !allowed {
		return nil, ErrClientConsentFailed
	}
	checked, err := b.profiles.CheckVerification(ctx, &profilev1.CheckVerificationRequest{
		Id: challenge.GetID(), Code: consent.code,
	})
	if err != nil || !checked.GetSuccess() {
		return nil, ErrClientConsentFailed
	}
	used, err := b.consentRepo.MarkUsed(ctx, challenge.GetID(), now)
	if err != nil || !used {
		return nil, ErrClientConsentFailed
	}
	return nil, nil //nolint:nilnil // consent given: the caller activates the client
}

// startConsent sends a code to the client's consent contact and records
// the challenge. The pending response is the client as the agent already
// sees it, still CREATED, with the opaque challenge id.
func (b *clientBusiness) startConsent(
	ctx context.Context,
	client *models.Client,
	scope *callerScope,
	now time.Time,
) (*fieldv1.ClientObject, error) {
	if client.ConsentContactID == "" {
		return nil, ErrClientConsentUnreachable
	}
	challenge := &models.ClientConsentChallenge{
		ProfileID: client.ProfileID,
		ContactID: client.ConsentContactID,
		MemberID:  scope.member.GetID(),
		ExpiresAt: now.Add(consentCodeTTL),
	}
	challenge.GenID(ctx)
	if err := b.consentRepo.Create(ctx, challenge); err != nil {
		return nil, err
	}
	if _, err := b.profiles.CreateContactVerification(ctx, &profilev1.CreateContactVerificationRequest{
		Id:               challenge.GetID(),
		ContactId:        client.ConsentContactID,
		DurationToExpire: consentCodeTTL.String(),
	}); err != nil {
		util.Log(ctx).WithError(err).Warn("could not send the consent code")
		return nil, ErrClientProfileUnavailable
	}
	pending := presentClient(client, false)
	props := data.JSONMap(pending.GetProperties().AsMap())
	props[consentVerificationIDKey] = challenge.GetID()
	props[consentStatusKey] = consentStatusPending
	pending.Properties = props.ToProtoStruct()
	return pending, nil
}

// consentContactID picks the contact an existing person's activation code
// goes to: their verified, active mobile contact. A person with none is
// activated by staff.
func consentContactID(profile *profilev1.ProfileObject) string {
	for _, c := range profile.GetContacts() {
		if c.GetType() == profilev1.ContactType_MSISDN && c.GetVerified() && c.GetId() != "" &&
			c.GetState() != commonv1.STATE_DELETED && c.GetState() != commonv1.STATE_INACTIVE {
			return c.GetId()
		}
	}
	return ""
}

// registeredContactID is the mobile contact a profile was just created
// with: the one the activation code goes to, verifying it on the way.
func registeredContactID(profile *profilev1.ProfileObject) string {
	for _, c := range profile.GetContacts() {
		if c.GetType() == profilev1.ContactType_MSISDN && c.GetId() != "" &&
			c.GetState() != commonv1.STATE_DELETED && c.GetState() != commonv1.STATE_INACTIVE {
			return c.GetId()
		}
	}
	return ""
}
