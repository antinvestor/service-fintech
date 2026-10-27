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
	"encoding/json"
	"errors"
	"fmt"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"

	"connectrpc.com/connect/v2"
	"gorm.io/gorm"

	"github.com/antinvestor/service-fintech/apps/stawi/service/handlers"
	"github.com/antinvestor/service-fintech/apps/stawi/service/models"
	"github.com/antinvestor/service-fintech/pkg/apperrors"
)

// fakeResponder answers every offer with the configured outcome.
type fakeResponder struct {
	offer *models.LoanOffer
	err   error

	groupID, offerID string
	response         int32
}

func (f *fakeResponder) Respond(_ context.Context, groupID, offerID string, response int32) (*models.LoanOffer, error) {
	f.groupID, f.offerID, f.response = groupID, offerID, response
	return f.offer, f.err
}

func TestRespondRouteAnswersTheOffer(t *testing.T) {
	t.Parallel()

	responder := &fakeResponder{offer: &models.LoanOffer{OriginationStatus: models.OriginationPending}}
	mux := http.NewServeMux()
	handlers.RegisterRoutes(mux, responder)

	rec := httptest.NewRecorder()
	mux.ServeHTTP(rec, httptest.NewRequest(http.MethodPost, respondRoute, strings.NewReader(`{"response":1}`)))

	if rec.Code != http.StatusOK {
		t.Fatalf("status = %d (body %s)", rec.Code, rec.Body.String())
	}
	if responder.groupID != "g-1" || responder.offerID != "o-1" || responder.response != 1 {
		t.Fatalf("answered %s/%s with %d", responder.groupID, responder.offerID, responder.response)
	}
	var body map[string]any
	if err := json.Unmarshal(rec.Body.Bytes(), &body); err != nil {
		t.Fatalf("decode body: %v", err)
	}
	if body["origination_status"] != models.OriginationPending {
		t.Errorf("origination_status = %v, want pending", body["origination_status"])
	}
}

// TestRespondRouteStatusCodes asserts the error contract of the JSON route:
// permanent failures come back as 4xx with a stable code, transient ones as
// 5xx, and no response echoes internal detail.
func TestRespondRouteStatusCodes(t *testing.T) {
	t.Parallel()

	const leaked = "payer Jane Doe (profile 9f3a) in group cabc123"

	tests := []struct {
		name       string
		err        error
		wantStatus int
		wantCode   string
		wantBody   string
	}{
		{
			name:       "authored not-found is 404",
			err:        apperrors.ErrDataNotFound.Extend("loan offer"),
			wantStatus: http.StatusNotFound,
			wantCode:   "not_found",
			wantBody:   "Requested data not found - loan offer",
		},
		{
			name:       "authored forbidden is 403",
			err:        apperrors.NewError(apperrors.Forbidden, "a member may only answer their own loan offer"),
			wantStatus: http.StatusForbidden,
			wantCode:   "forbidden",
			wantBody:   "a member may only answer their own loan offer",
		},
		{
			name:       "authored unprocessable is 422",
			err:        apperrors.NewError(apperrors.Unprocessable, "loan offer is no longer open"),
			wantStatus: http.StatusUnprocessableEntity,
			wantCode:   "unprocessable",
			wantBody:   "loan offer is no longer open",
		},
		{
			name:       "wrapped authored error keeps its class",
			err:        fmt.Errorf("respond: %w", apperrors.NewError(apperrors.Gone, "loan offer has expired")),
			wantStatus: http.StatusGone,
			wantCode:   "gone",
			wantBody:   "loan offer has expired",
		},
		{
			name:       "peer not-found is 404 without the peer message",
			err:        fmt.Errorf("membership get: %w", connect.NewError(connect.CodeNotFound, leaked)),
			wantStatus: http.StatusNotFound,
			wantCode:   "not_found",
			wantBody:   "the requested record was not found",
		},
		{
			name:       "peer failed precondition is 422",
			err:        connect.NewError(connect.CodeFailedPrecondition, leaked),
			wantStatus: http.StatusUnprocessableEntity,
			wantCode:   "unprocessable",
			wantBody:   "the operation is not allowed in the record's current state",
		},
		{
			name:       "peer unavailable is retriable 503",
			err:        connect.NewError(connect.CodeUnavailable, leaked),
			wantStatus: http.StatusServiceUnavailable,
			wantCode:   "unavailable",
			wantBody:   "a dependency is temporarily unavailable",
		},
		{
			name:       "database no rows is 404",
			err:        fmt.Errorf("loan offer: %w", gorm.ErrRecordNotFound),
			wantStatus: http.StatusNotFound,
			wantCode:   "not_found",
			wantBody:   "the requested record was not found",
		},
		{
			name:       "database duplicate key is 409",
			err:        gorm.ErrDuplicatedKey,
			wantStatus: http.StatusConflict,
			wantCode:   "conflict",
			wantBody:   "the record was changed by another request",
		},
		{
			name:       "deadline exceeded is retriable 504",
			err:        fmt.Errorf("loans: %w", context.DeadlineExceeded),
			wantStatus: http.StatusGatewayTimeout,
			wantCode:   "timeout",
			wantBody:   "the operation timed out",
		},
		{
			name:       "unclassified error is a sanitised 500",
			err:        errors.New(leaked),
			wantStatus: http.StatusInternalServerError,
			wantCode:   "internal",
			wantBody:   "an internal error occurred",
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			t.Parallel()

			mux := http.NewServeMux()
			handlers.RegisterRoutes(mux, &fakeResponder{err: tt.err})

			rec := httptest.NewRecorder()
			mux.ServeHTTP(rec, httptest.NewRequest(http.MethodPost, respondRoute, strings.NewReader(`{"response":1}`)))

			if rec.Code != tt.wantStatus {
				t.Fatalf("status = %d, want %d (body %s)", rec.Code, tt.wantStatus, rec.Body.String())
			}
			if ct := rec.Header().Get("Content-Type"); ct != "application/json" {
				t.Errorf("content-type = %q, want application/json", ct)
			}

			var body struct {
				Error string `json:"error"`
				Code  string `json:"code"`
			}
			if err := json.Unmarshal(rec.Body.Bytes(), &body); err != nil {
				t.Fatalf("decode body %q: %v", rec.Body.String(), err)
			}
			if body.Code != tt.wantCode {
				t.Errorf("code = %q, want %q", body.Code, tt.wantCode)
			}
			if body.Error != tt.wantBody {
				t.Errorf("error = %q, want %q", body.Error, tt.wantBody)
			}
			if strings.Contains(rec.Body.String(), "Jane Doe") || strings.Contains(rec.Body.String(), "9f3a") {
				t.Errorf("response leaks internal detail: %s", rec.Body.String())
			}
		})
	}
}

func TestRespondRouteRejectsABodyThatIsNotJSON(t *testing.T) {
	t.Parallel()

	mux := http.NewServeMux()
	handlers.RegisterRoutes(mux, &fakeResponder{})
	rec := httptest.NewRecorder()
	mux.ServeHTTP(rec, httptest.NewRequest(http.MethodPost, respondRoute, strings.NewReader("accept")))
	if rec.Code != http.StatusBadRequest {
		t.Fatalf("status = %d, want 400", rec.Code)
	}
}
