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
	"time"

	"buf.build/gen/go/antinvestor/limits/connectrpc/go/limits/v1/limitsv1connect"
	limitsv1 "buf.build/gen/go/antinvestor/limits/protocolbuffers/go/limits/v1"
	"connectrpc.com/connect"

	"github.com/antinvestor/service-fintech/apps/limits/service/business"
)

// defaultReserveTTL applies when the caller does not provide a reservation TTL.
const defaultReserveTTL = 5 * time.Minute

// RuntimeService implements limitsv1connect.LimitsServiceHandler. It
// wraps ReservationBusiness in connect-rpc shape; all business logic
// lives in the business layer.
type RuntimeService struct {
	limitsv1connect.UnimplementedLimitsServiceHandler
	biz business.ReservationBusiness
}

// NewRuntimeService constructs a Connect handler backed by the given business layer.
func NewRuntimeService(biz business.ReservationBusiness) *RuntimeService {
	return &RuntimeService{biz: biz}
}

// Check evaluates a LimitIntent without persisting anything.
func (s *RuntimeService) Check(
	ctx context.Context,
	req *connect.Request[limitsv1.CheckRequest],
) (*connect.Response[limitsv1.CheckResponse], error) {
	out, err := s.biz.Check(ctx, req.Msg.GetIntent())
	if err != nil {
		return nil, err
	}
	return connect.NewResponse(out), nil
}

// Reserve creates a reservation for the given intent.
func (s *RuntimeService) Reserve(
	ctx context.Context,
	req *connect.Request[limitsv1.ReserveRequest],
) (*connect.Response[limitsv1.ReserveResponse], error) {
	ttl := req.Msg.GetTtl().AsDuration()
	if ttl <= 0 {
		ttl = defaultReserveTTL
	}
	out, err := s.biz.Reserve(ctx, req.Msg.GetIntent(), req.Msg.GetIdempotencyKey(), ttl)
	if err != nil {
		return nil, err
	}
	return connect.NewResponse(out), nil
}

// Commit transitions an active reservation to committed and materialises ledger entries.
func (s *RuntimeService) Commit(
	ctx context.Context,
	req *connect.Request[limitsv1.CommitRequest],
) (*connect.Response[limitsv1.CommitResponse], error) {
	out, err := s.biz.Commit(ctx, req.Msg.GetReservationId())
	if err != nil {
		return nil, err
	}
	return connect.NewResponse(out), nil
}

// Release cancels an active or pending-approval reservation.
func (s *RuntimeService) Release(
	ctx context.Context,
	req *connect.Request[limitsv1.ReleaseRequest],
) (*connect.Response[limitsv1.ReleaseResponse], error) {
	out, err := s.biz.Release(ctx, req.Msg.GetReservationId(), req.Msg.GetReason())
	if err != nil {
		return nil, err
	}
	return connect.NewResponse(out), nil
}

// Reverse creates a reversal traceability record and marks the committed reservation reversed.
func (s *RuntimeService) Reverse(
	ctx context.Context,
	req *connect.Request[limitsv1.ReverseRequest],
) (*connect.Response[limitsv1.ReverseResponse], error) {
	out, err := s.biz.Reverse(ctx, req.Msg.GetReservationId(), req.Msg.GetIdempotencyKey(), req.Msg.GetReason())
	if err != nil {
		return nil, err
	}
	return connect.NewResponse(out), nil
}
