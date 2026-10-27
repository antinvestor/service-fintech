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

package handlers

import (
	"context"
	"math"

	"google.golang.org/protobuf/types/known/structpb"

	"github.com/antinvestor/service-fintech/apps/stawi/service/business"
	"github.com/antinvestor/service-fintech/gen/go/stawi/connectrpc/go/stawi/v1/stawiv1connect"
	stawiv1 "github.com/antinvestor/service-fintech/gen/go/stawi/protocolbuffers/go/stawi/v1"
	"github.com/antinvestor/service-fintech/pkg/apperrors"
)

// JobRunner runs one batch of a periodic job.
type JobRunner interface {
	Run(ctx context.Context, job stawiv1.StawiJob, batch int) (int, bool, error)
}

// StawiServer implements StawiService. Per-RPC permissions are enforced by
// the function access interceptor.
type StawiServer struct {
	jobs   JobRunner
	offers LoanOfferResponder

	stawiv1connect.UnimplementedStawiServiceHandler
}

// NewStawiServer builds the Connect handler.
func NewStawiServer(jobs JobRunner, offers LoanOfferResponder) *StawiServer {
	return &StawiServer{jobs: jobs, offers: offers}
}

// StawiJobRun runs one batch of a periodic job for the platform scheduler.
func (s *StawiServer) StawiJobRun(
	ctx context.Context,
	req *stawiv1.StawiJobRunRequest,
) (*stawiv1.StawiJobRunResponse, error) {
	if s.jobs == nil {
		return nil, apperrors.CleanErr(business.ErrUnknownJob)
	}
	processed, more, err := s.jobs.Run(ctx, req.GetJob(), int(req.GetBatchSize()))
	if err != nil {
		return nil, apperrors.CleanErr(err)
	}
	return &stawiv1.StawiJobRunResponse{
		Processed: int32(min(processed, math.MaxInt32)), //nolint:gosec // clamped to int32
		More:      more,
	}, nil
}

// LoanOfferRespond records a member's answer to a loan offer.
func (s *StawiServer) LoanOfferRespond(
	ctx context.Context,
	req *stawiv1.LoanOfferRespondRequest,
) (*stawiv1.LoanOfferRespondResponse, error) {
	offer, err := s.offers.Respond(ctx, req.GetGroupId(), req.GetOfferId(), req.GetResponse())
	if err != nil {
		return nil, apperrors.CleanErr(err)
	}
	result, err := structpb.NewStruct(offerResult(req.GetOfferId(), req.GetResponse(), offer))
	if err != nil {
		return nil, apperrors.CleanErr(err)
	}
	return &stawiv1.LoanOfferRespondResponse{Data: result}, nil
}
