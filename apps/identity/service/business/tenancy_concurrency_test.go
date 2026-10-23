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
	"sync"

	identityv1 "buf.build/gen/go/antinvestor/identity/protocolbuffers/go/identity/v1"
	"github.com/golang-jwt/jwt/v5"
	"github.com/pitabwire/frame/v2/security"
)

// asPartition returns a context whose claims name otherPartition as the acting
// partition while still granting access to the suite's primary partition, the
// shape a workforce member with access to several branches carries. Without
// both partitions in the claim, RLS would refuse the read outright and the
// re-homing this test guards against could not be observed.
func (e *approvalWorkflowEnv) asPartition(otherPartition string) context.Context {
	claims := security.ClaimsFromContext(e.ctx)
	return (&security.AuthenticationClaims{
		TenantID:    claims.GetTenantID(),
		PartitionID: otherPartition,
		Ext:         map[string]any{"partition_ids": []string{claims.GetPartitionID()}},
		RegisteredClaims: jwt.RegisteredClaims{
			Subject: "profile-other-partition",
		},
	}).ClaimsToContext(e.ctx)
}

// TestInternalTeamEditFromAnotherPartitionDoesNotRehomeRow covers the save
// paths that rebuild the model from the API object. GenID stamps tenancy from
// the editor's claims, so before carryStoredTenancy an edit made from a second
// partition silently moved the row into that partition.
func (s *approvalWorkflowSuite) TestInternalTeamEditFromAnotherPartitionDoesNotRehomeRow() {
	env := s.newEnv()
	org := env.createOrganization("Org Team Tenancy", "org-team-tenancy")
	homePartition := security.ClaimsFromContext(env.ctx).GetPartitionID()

	created, err := env.workforceBusiness.InternalTeamSave(env.ctx, &identityv1.InternalTeamObject{
		OrganizationId: org.GetID(),
		Name:           "Collections Team",
		Code:           "collections-team",
		TeamType:       "collections",
	})
	s.Require().NoError(err)

	stored, err := env.internalTeamRepo.GetByID(env.ctx, created.GetId())
	s.Require().NoError(err)
	s.Require().Equal(homePartition, stored.PartitionID)

	// Same row, edited by a principal acting in another partition.
	otherCtx := env.asPartition("partition-other")
	_, err = env.workforceBusiness.InternalTeamSave(otherCtx, &identityv1.InternalTeamObject{
		Id:             created.GetId(),
		OrganizationId: org.GetID(),
		Name:           "Collections Team Renamed",
		Code:           "collections-team",
		TeamType:       "collections",
	})
	s.Require().NoError(err)

	reloaded, err := env.internalTeamRepo.GetByID(env.ctx, created.GetId())
	s.Require().NoError(err)
	s.Equal("Collections Team Renamed", reloaded.Name, "the edit must still apply")
	s.Equal(homePartition, reloaded.PartitionID, "an edit must not re-home the row")
	s.Equal(stored.TenantID, reloaded.TenantID)
	s.Equal(stored.CreatedBy, reloaded.CreatedBy, "creation attribution must survive an edit")
}

// TestConcurrentApproveAndRejectOnlyOneWins covers the read-check-emit race:
// two decisions both read a pending case, both passed the status check, and
// both emitted. The conditional update makes exactly one of them land.
func (s *approvalWorkflowSuite) TestConcurrentApproveAndRejectOnlyOneWins() {
	env := s.newEnv()

	approvalCaseBusiness := NewApprovalCaseBusiness(env.ctx, env.eventsMan, env.approvalCaseRepo, nil)

	submitted, err := approvalCaseBusiness.Submit(env.ctx, ApprovalCaseSubmission{
		SubjectType: approvalCaseSubjectBranch,
		SubjectID:   "subject-race",
		CaseType:    approvalCaseTypeBranchCreate,
		Summary:     "race between approve and reject",
	})
	s.Require().NoError(err)
	s.Require().Equal(approvalCaseStatusPendingApproval, submitted.Status)

	approverCtx := env.asProfile("profile-approver")
	rejecterCtx := env.asProfile("profile-rejecter")

	var wg sync.WaitGroup
	var approveErr, rejectErr error
	wg.Add(2)
	go func() {
		defer wg.Done()
		_, approveErr = approvalCaseBusiness.Approve(approverCtx, submitted.GetID(), "approved")
	}()
	go func() {
		defer wg.Done()
		_, rejectErr = approvalCaseBusiness.Reject(rejecterCtx, submitted.GetID(), "rejected")
	}()
	wg.Wait()

	s.Require().False(approveErr == nil && rejectErr == nil,
		"approve and reject must not both succeed on the same case")
	s.Require().False(approveErr != nil && rejectErr != nil,
		"one of the two decisions must land: approve=%v reject=%v", approveErr, rejectErr)

	final, err := env.approvalCaseRepo.GetByID(env.ctx, submitted.GetID())
	s.Require().NoError(err)
	if approveErr == nil {
		s.Equal(approvalCaseStatusApproved, final.Status)
		s.Empty(final.RejectedBy)
	} else {
		s.Equal(approvalCaseStatusRejected, final.Status)
		s.Empty(final.ApprovedBy)
	}
}

// TestSubmitRejectsSecondOpenCaseForSameSubject covers the partial unique index
// that backs Submit: the pre-read alone could not stop two concurrent
// submissions from both creating an open case.
func (s *approvalWorkflowSuite) TestSubmitRejectsSecondOpenCaseForSameSubject() {
	env := s.newEnv()
	approvalCaseBusiness := NewApprovalCaseBusiness(env.ctx, env.eventsMan, env.approvalCaseRepo, nil)

	submission := ApprovalCaseSubmission{
		SubjectType: approvalCaseSubjectBranch,
		SubjectID:   "subject-double-submit",
		CaseType:    approvalCaseTypeBranchCreate,
		Summary:     "first",
	}

	_, err := approvalCaseBusiness.Submit(env.ctx, submission)
	s.Require().NoError(err)

	_, err = approvalCaseBusiness.Submit(env.ctx, submission)
	s.Require().Error(err)
	s.ErrorIs(err, ErrApprovalCaseAlreadyPending)
}
