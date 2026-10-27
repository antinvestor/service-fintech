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

package handlers_test

import (
	"context"
	"testing"

	"connectrpc.com/connect/v2"

	"github.com/antinvestor/service-fintech/apps/stawi/service/business"
	"github.com/antinvestor/service-fintech/apps/stawi/service/handlers"
	"github.com/antinvestor/service-fintech/apps/stawi/service/models"
	stawiv1 "github.com/antinvestor/service-fintech/gen/go/stawi/protocolbuffers/go/stawi/v1"
)

type fakeJobs struct {
	job       stawiv1.StawiJob
	batch     int
	processed int
	more      bool
	err       error
}

func (f *fakeJobs) Run(_ context.Context, job stawiv1.StawiJob, batch int) (int, bool, error) {
	f.job, f.batch = job, batch
	return f.processed, f.more, f.err
}

func TestStawiJobRunRunsTheNamedJob(t *testing.T) {
	t.Parallel()

	jobs := &fakeJobs{processed: 7, more: true}
	server := handlers.NewStawiServer(jobs, &fakeResponder{})
	resp, err := server.StawiJobRun(t.Context(), &stawiv1.StawiJobRunRequest{
		Job: stawiv1.StawiJob_STAWI_JOB_CLOSE_DUE_PERIODS, BatchSize: 25,
	})
	if err != nil {
		t.Fatalf("run: %v", err)
	}
	if jobs.job != stawiv1.StawiJob_STAWI_JOB_CLOSE_DUE_PERIODS || jobs.batch != 25 {
		t.Fatalf("ran %v with batch %d", jobs.job, jobs.batch)
	}
	if resp.GetProcessed() != 7 || !resp.GetMore() {
		t.Fatalf("response = %v", resp)
	}
}

// A caller that is not an internal service is refused as permission denied.
func TestStawiJobRunRefusesCallersThatAreNotInternal(t *testing.T) {
	t.Parallel()

	server := handlers.NewStawiServer(&fakeJobs{err: business.ErrJobCallerNotInternal}, &fakeResponder{})
	_, err := server.StawiJobRun(t.Context(), &stawiv1.StawiJobRunRequest{
		Job: stawiv1.StawiJob_STAWI_JOB_LOAN_OFFERS,
	})
	if connect.CodeOf(err) != connect.CodePermissionDenied {
		t.Fatalf("code = %v, want permission denied", connect.CodeOf(err))
	}
}

func TestLoanOfferRespondOverConnect(t *testing.T) {
	t.Parallel()

	responder := &fakeResponder{offer: &models.LoanOffer{
		OriginationStatus: models.OriginationDisbursed, LoanAccountID: "loan-1",
	}}
	server := handlers.NewStawiServer(&fakeJobs{}, responder)
	resp, err := server.LoanOfferRespond(t.Context(), &stawiv1.LoanOfferRespondRequest{
		GroupId: "g-1", OfferId: "o-1", Response: 1,
	})
	if err != nil {
		t.Fatalf("respond: %v", err)
	}
	if responder.offerID != "o-1" || responder.response != 1 {
		t.Fatalf("answered %s with %d", responder.offerID, responder.response)
	}
	if got := resp.GetData().AsMap()["loan_account_id"]; got != "loan-1" {
		t.Fatalf("loan_account_id = %v", got)
	}
}
