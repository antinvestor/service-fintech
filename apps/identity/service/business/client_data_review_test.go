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
	"sync"
	"time"

	identityv1 "buf.build/gen/go/antinvestor/identity/protocolbuffers/go/identity/v1"

	"github.com/antinvestor/service-fintech/apps/identity/service/models"
)

const (
	statusCollected   = identityv1.DataVerificationStatus_DATA_VERIFICATION_STATUS_COLLECTED
	statusUnderReview = identityv1.DataVerificationStatus_DATA_VERIFICATION_STATUS_UNDER_REVIEW
	statusVerified    = identityv1.DataVerificationStatus_DATA_VERIFICATION_STATUS_VERIFIED
	statusExpired     = identityv1.DataVerificationStatus_DATA_VERIFICATION_STATUS_EXPIRED
)

// Two reviewers who open the same entry at once: exactly one holds it, and
// only the holder can decide it.
func (s *approvalWorkflowSuite) TestClientDataStartReviewHoldsTheEntryForOneReviewer() {
	env := s.newEnv()
	clientData := env.clientDataBusiness()
	env.ensureClient("client-claim")

	entry, err := clientData.Save(env.ctx, &models.ClientDataEntry{
		ClientID: "client-claim", FieldKey: "national_id", Value: "CM1", ValueType: "text",
	})
	s.Require().NoError(err)

	reviewers := []string{"profile-reviewer-a", "profile-reviewer-b"}
	errs := make([]error, len(reviewers))
	var wg sync.WaitGroup
	wg.Add(len(reviewers))
	for i, reviewer := range reviewers {
		go func() {
			defer wg.Done()
			_, errs[i] = clientData.StartReview(env.asProfile(reviewer), entry.GetID())
		}()
	}
	wg.Wait()

	holder, other := -1, -1
	for i, claimErr := range errs {
		if claimErr == nil {
			s.Require().Equal(-1, holder, "two reviewers must not both hold the entry")
			holder = i
			continue
		}
		s.Require().ErrorIs(claimErr, ErrClientDataEntryHeldByAnotherReviewer)
		other = i
	}
	s.Require().NotEqual(-1, holder, "one reviewer must hold the entry")
	s.Require().NotEqual(-1, other)

	stored, err := env.clientDataRepo.GetByID(env.ctx, entry.GetID())
	s.Require().NoError(err)
	s.EqualValues(statusUnderReview, stored.VerificationStatus)
	s.Equal(reviewers[holder], stored.ReviewerID)
	s.Equal(entry.ModifiedBy, stored.ModifiedBy, "the claim must not erase who submitted the value")

	// The other reviewer can neither decide it nor take it while the hold is fresh.
	_, err = clientData.Verify(env.asProfile(reviewers[other]), entry.GetID(), "looks fine")
	s.Require().ErrorIs(err, ErrClientDataEntryHeldByAnotherReviewer)

	// Claiming again is harmless for the holder, who then decides it.
	_, err = clientData.StartReview(env.asProfile(reviewers[holder]), entry.GetID())
	s.Require().NoError(err)
	verified, err := clientData.Verify(env.asProfile(reviewers[holder]), entry.GetID(), "documents match")
	s.Require().NoError(err)
	s.EqualValues(statusVerified, verified.VerificationStatus)

	history, err := env.clientDataHist.GetByEntryID(env.ctx, entry.GetID())
	s.Require().NoError(err)
	actions := make([]string, 0, len(history))
	for _, h := range history {
		actions = append(actions, h.Action)
	}
	s.Contains(actions, actionReview)
	s.Contains(actions, actionVerified)
}

// A hold left untouched past the claim TTL can be taken over, and the
// original reviewer then loses the right to decide.
func (s *approvalWorkflowSuite) TestClientDataStaleReviewCanBeTakenOver() {
	env := s.newEnv()
	clientData := env.clientDataBusiness()
	env.ensureClient("client-stale")

	entry, err := clientData.Save(env.ctx, &models.ClientDataEntry{
		ClientID: "client-stale", FieldKey: "national_id", Value: "CM2", ValueType: "text",
	})
	s.Require().NoError(err)
	_, err = clientData.StartReview(env.asProfile("profile-away"), entry.GetID())
	s.Require().NoError(err)

	s.Require().NoError(env.clientDataRepo.Pool().DB(env.ctx, false).
		Table("client_data_entries").Where("id = ?", entry.GetID()).
		Update("modified_at", time.Now().UTC().Add(-reviewClaimTTL-time.Minute)).Error)

	taken, err := clientData.StartReview(env.asProfile("profile-cover"), entry.GetID())
	s.Require().NoError(err)
	s.Equal("profile-cover", taken.ReviewerID)

	_, err = clientData.Reject(env.asProfile("profile-away"), entry.GetID(), "blurry")
	s.Require().ErrorIs(err, ErrClientDataEntryHeldByAnotherReviewer)
}

// A document past its expiry date reads as EXPIRED at once, everywhere: on
// the entry, in a status-filtered list, and to reviewers, who can no longer
// decide it. Resubmitting the document starts it over.
func (s *approvalWorkflowSuite) TestClientDataExpiresOnItsDate() {
	env := s.newEnv()
	clientData := env.clientDataBusiness()
	env.ensureClient("client-expiry")

	expired := time.Now().UTC().Add(-time.Hour)
	entry, err := clientData.Save(env.ctx, &models.ClientDataEntry{
		ClientID: "client-expiry", FieldKey: "passport", Value: "P1", ValueType: "text", ExpiresAt: &expired,
	})
	s.Require().NoError(err)
	s.Equal(statusExpired, entry.ToAPI().GetVerificationStatus())

	_, err = clientData.Verify(env.asProfile("profile-checker"), entry.GetID(), "")
	s.Require().ErrorIs(err, ErrClientDataEntryExpired)
	_, err = clientData.StartReview(env.asProfile("profile-checker"), entry.GetID())
	s.Require().ErrorIs(err, ErrClientDataEntryExpired)

	listed, err := clientData.List(env.ctx, "client-expiry", int32(statusExpired), 0, 10)
	s.Require().NoError(err)
	s.Len(listed, 1)
	listed, err = clientData.List(env.ctx, "client-expiry", int32(statusCollected), 0, 10)
	s.Require().NoError(err)
	s.Empty(listed, "an expired document must not be listed as awaiting review")

	renewed := time.Now().UTC().AddDate(5, 0, 0)
	resubmitted, err := clientData.Save(env.ctx, &models.ClientDataEntry{
		ClientID: "client-expiry", FieldKey: "passport", Value: "P2", ValueType: "text", ExpiresAt: &renewed,
	})
	s.Require().NoError(err)
	s.Equal(statusCollected, resubmitted.ToAPI().GetVerificationStatus())
	_, err = clientData.Verify(env.asProfile("profile-checker"), entry.GetID(), "renewed passport")
	s.Require().NoError(err)
}

// A verified document whose expiry date then passes stops counting as
// verified, without any job restamping the row.
func (s *approvalWorkflowSuite) TestVerifiedClientDataLapsesAtExpiry() {
	env := s.newEnv()
	clientData := env.clientDataBusiness()
	env.ensureClient("client-lapse")

	soon := time.Now().UTC().Add(time.Hour)
	entry, err := clientData.Save(env.ctx, &models.ClientDataEntry{
		ClientID: "client-lapse", FieldKey: "permit", Value: "W1", ValueType: "text", ExpiresAt: &soon,
	})
	s.Require().NoError(err)
	verified, err := clientData.Verify(env.asProfile("profile-checker"), entry.GetID(), "")
	s.Require().NoError(err)
	s.Equal(statusVerified, verified.ToAPI().GetVerificationStatus())

	s.Equal(statusExpired, verified.EffectiveStatus(soon), "at the expiry instant it lapses")
	s.Require().NoError(env.clientDataRepo.Pool().DB(env.ctx, false).
		Table("client_data_entries").Where("id = ?", entry.GetID()).
		Update("expires_at", time.Now().UTC().Add(-time.Minute)).Error)

	listed, err := clientData.List(env.ctx, "client-lapse", int32(statusVerified), 0, 10)
	s.Require().NoError(err)
	s.Empty(listed, "a lapsed document is no longer listed as verified")
	stored, err := env.clientDataRepo.GetByID(env.ctx, entry.GetID())
	s.Require().NoError(err)
	s.Equal(statusExpired, stored.ToAPI().GetVerificationStatus())
}
