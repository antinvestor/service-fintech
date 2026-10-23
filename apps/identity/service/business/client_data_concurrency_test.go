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
	"errors"
	"fmt"
	"sync"

	identityv1 "buf.build/gen/go/antinvestor/identity/protocolbuffers/go/identity/v1"
	"github.com/pitabwire/frame/v2/data"

	"github.com/antinvestor/service-fintech/apps/identity/service/models"
)

// TestClientDataSaveConcurrentResubmissionsSerialize covers the lost-update
// race on ClientDataSave: before the row lock, every concurrent resubmission
// read revision N and every one of them landed as N+1, so the audit trail
// showed one revision for several distinct values.
func (s *approvalWorkflowSuite) TestClientDataSaveConcurrentResubmissionsSerialize() {
	env := s.newEnv()
	clientData := NewClientDataBusiness(env.ctx, env.eventsMan, env.clientDataRepo, env.clientDataHist)

	first, err := clientData.Save(env.ctx, &models.ClientDataEntry{
		ClientID:  "client-race",
		FieldKey:  "national_id",
		Value:     "CM0",
		ValueType: "text",
	})
	s.Require().NoError(err)
	s.Require().EqualValues(1, first.Revision)

	const writers = 4
	var wg sync.WaitGroup
	errs := make([]error, writers)
	revisions := make([]int32, writers)
	wg.Add(writers)
	for i := range writers {
		go func() {
			defer wg.Done()
			saved, saveErr := clientData.Save(env.ctx, &models.ClientDataEntry{
				ClientID:  "client-race",
				FieldKey:  "national_id",
				Value:     fmt.Sprintf("CM%d", i+1),
				ValueType: "text",
			})
			errs[i] = saveErr
			if saveErr == nil {
				revisions[i] = saved.Revision
			}
		}()
	}
	wg.Wait()

	seen := map[int32]bool{}
	for i := range writers {
		s.Require().NoError(errs[i], "a resubmission that waited for the lock must still land")
		s.False(seen[revisions[i]], "two resubmissions must never share revision %d", revisions[i])
		seen[revisions[i]] = true
	}

	final, err := env.clientDataRepo.GetByClientAndKey(env.ctx, "client-race", "national_id")
	s.Require().NoError(err)
	s.EqualValues(1+writers, final.Revision, "each serialized write must add exactly one revision")
	s.Equal(first.GetID(), final.GetID(), "resubmissions must update the row, not create a second one")
	s.Equal(
		int32(identityv1.DataVerificationStatus_DATA_VERIFICATION_STATUS_COLLECTED),
		final.VerificationStatus,
	)

	history, err := env.clientDataHist.GetByEntryID(env.ctx, first.GetID())
	s.Require().NoError(err)
	s.Len(history, 1+writers, "every landed revision must leave one history row")
	for i, h := range history {
		s.EqualValues(i+1, h.Revision, "history must read as one contiguous revision sequence")
	}
}

// TestClientDataSaveConcurrentFirstSubmissionsNeverDuplicate covers the insert
// side of the same race: with no row to lock, two first submissions both take
// the create path and the unique index decides. The loser used to be swallowed
// as a duplicate-key "success"; it must now be reported so the client retries.
func (s *approvalWorkflowSuite) TestClientDataSaveConcurrentFirstSubmissionsNeverDuplicate() {
	env := s.newEnv()
	clientData := NewClientDataBusiness(env.ctx, env.eventsMan, env.clientDataRepo, env.clientDataHist)

	const writers = 3
	var wg sync.WaitGroup
	errs := make([]error, writers)
	wg.Add(writers)
	for i := range writers {
		go func() {
			defer wg.Done()
			_, errs[i] = clientData.Save(env.ctx, &models.ClientDataEntry{
				ClientID:  "client-first",
				FieldKey:  "passport_photo",
				Value:     fmt.Sprintf("https://files.example.com/p%d", i),
				ValueType: "photo",
			})
		}()
	}
	wg.Wait()

	landed := 0
	for _, err := range errs {
		if err == nil {
			landed++
			continue
		}
		s.Require().ErrorIs(err, ErrClientDataEntryConflict,
			"a losing first submission must surface as a conflict")
	}
	s.Require().GreaterOrEqual(landed, 1, "at least one first submission must land")

	var rows []*models.ClientDataEntry
	s.Require().NoError(env.clientDataRepo.Pool().DB(env.ctx, true).
		Where("client_id = ? AND field_key = ?", "client-first", "passport_photo").
		Find(&rows).Error)
	s.Require().Len(rows, 1, "the unique index must hold: one row per (client, field)")
	s.EqualValues(landed, rows[0].Revision, "the row must carry exactly one revision per landed write")
}

// TestFormTemplatePublishConcurrentOnlyOneWins covers the read-modify-write on
// Publish: two publishes both read a draft, both bumped the version in memory
// and both emitted, so the template version moved by one while both callers
// were told they published.
func (s *approvalWorkflowSuite) TestFormTemplatePublishConcurrentOnlyOneWins() {
	env := s.newEnv()
	templates := NewFormTemplateBusiness(env.ctx, env.eventsMan, env.formTemplateRepo)

	draft := &models.FormTemplate{
		Name:       "KYC Onboarding",
		Status:     int32(identityv1.FormTemplateStatus_FORM_TEMPLATE_STATUS_DRAFT),
		EntityType: "client",
		Fields:     data.JSONMap{},
	}
	draft.GenID(env.ctx)
	s.Require().NoError(env.formTemplateRepo.Create(env.ctx, draft))

	var wg sync.WaitGroup
	var firstErr, secondErr error
	wg.Add(2)
	go func() {
		defer wg.Done()
		_, firstErr = templates.Publish(env.asProfile("profile-publisher-a"), draft.GetID())
	}()
	go func() {
		defer wg.Done()
		_, secondErr = templates.Publish(env.asProfile("profile-publisher-b"), draft.GetID())
	}()
	wg.Wait()

	s.Require().False(firstErr == nil && secondErr == nil, "both publishes must not succeed")
	s.Require().False(firstErr != nil && secondErr != nil,
		"one publish must land: first=%v second=%v", firstErr, secondErr)
	loser := firstErr
	if loser == nil {
		loser = secondErr
	}
	s.Require().ErrorIs(loser, ErrFormTemplateNotDraft)

	published, err := env.formTemplateRepo.GetByID(env.ctx, draft.GetID())
	s.Require().NoError(err)
	s.EqualValues(identityv1.FormTemplateStatus_FORM_TEMPLATE_STATUS_PUBLISHED, published.Status)
	s.EqualValues(1, published.TemplateVersion, "the version must be bumped exactly once")

	// A published template is terminal for Publish, even sequentially.
	_, err = templates.Publish(env.ctx, draft.GetID())
	s.ErrorIs(err, ErrFormTemplateNotDraft)
}

// TestClientDataConcurrentVerifyAndRejectOnlyOneWins covers the read-check-emit
// race on review: both decisions read a COLLECTED entry, both passed the
// status gate, and both emitted, so the last handled event silently won and
// the history showed two transitions for one entry.
func (s *approvalWorkflowSuite) TestClientDataConcurrentVerifyAndRejectOnlyOneWins() {
	env := s.newEnv()
	clientData := NewClientDataBusiness(env.ctx, env.eventsMan, env.clientDataRepo, env.clientDataHist)

	entry, err := clientData.Save(env.ctx, &models.ClientDataEntry{
		ClientID:  "client-review-race",
		FieldKey:  "national_id",
		Value:     "CM123",
		ValueType: "text",
	})
	s.Require().NoError(err)

	verifierCtx := env.asProfile("profile-verifier")
	rejecterCtx := env.asProfile("profile-rejecter")

	var wg sync.WaitGroup
	var verifyErr, rejectErr error
	wg.Add(2)
	go func() {
		defer wg.Done()
		_, verifyErr = clientData.Verify(verifierCtx, entry.GetID(), "documents match")
	}()
	go func() {
		defer wg.Done()
		_, rejectErr = clientData.Reject(rejecterCtx, entry.GetID(), "blurry scan")
	}()
	wg.Wait()

	s.Require().False(verifyErr == nil && rejectErr == nil, "verify and reject must not both succeed")
	s.Require().False(verifyErr != nil && rejectErr != nil,
		"one decision must land: verify=%v reject=%v", verifyErr, rejectErr)
	loser := verifyErr
	if loser == nil {
		loser = rejectErr
	}
	s.Require().True(
		errors.Is(loser, ErrClientDataEntryReviewConflict) || errors.Is(loser, ErrClientDataEntryNotReviewable),
		"the loser must be told its decision did not land, got %v", loser)

	final, err := env.clientDataRepo.GetByID(env.ctx, entry.GetID())
	s.Require().NoError(err)
	if verifyErr == nil {
		s.Equal(int32(identityv1.DataVerificationStatus_DATA_VERIFICATION_STATUS_VERIFIED), final.VerificationStatus)
		s.Equal("profile-verifier", final.ReviewerID)
		s.NotNil(final.VerifiedAt)
	} else {
		s.Equal(int32(identityv1.DataVerificationStatus_DATA_VERIFICATION_STATUS_REJECTED), final.VerificationStatus)
		s.Equal("profile-rejecter", final.ReviewerID)
		s.Nil(final.VerifiedAt)
	}

	history, err := env.clientDataHist.GetByEntryID(env.ctx, entry.GetID())
	s.Require().NoError(err)
	s.Require().Len(history, 2, "one submission plus exactly one transition")
	s.Equal(actionSubmitted, history[0].Action)
	if verifyErr == nil {
		s.Equal(actionVerified, history[1].Action)
	} else {
		s.Equal(actionRejected, history[1].Action)
	}

	// The entry is terminal: a later decision by anyone is refused.
	_, err = clientData.RequestInfo(env.asProfile("profile-third"), entry.GetID(), "more please")
	s.Require().ErrorIs(err, ErrClientDataEntryNotReviewable)
}
