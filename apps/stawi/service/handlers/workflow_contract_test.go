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
	"os"
	"path/filepath"
	"regexp"
	"strings"
	"testing"

	"connectrpc.com/connect/v2"
	"gorm.io/gorm"

	"github.com/antinvestor/service-fintech/apps/stawi/service/handlers"
	"github.com/antinvestor/service-fintech/apps/stawi/service/models"
	"github.com/antinvestor/service-fintech/pkg/apperrors"
)

// workflowsDir is the product's workflow definition directory relative to this
// package.
const workflowsDir = "../../../../products/stawi/workflows"

// templateExpr matches a Trustage interpolation such as {{ payload.group_id }}.
var templateExpr = regexp.MustCompile(`\{\{[^}]*\}\}`)

// TestWorkflowURLsResolveAgainstMux asserts the contract between the workflow
// definitions and the registered routes: every http.request step in
// products/stawi/workflows/*.json must resolve to a handler. A workflow that
// calls a URL nobody serves 404s at runtime, retries, and dies.
func TestWorkflowURLsResolveAgainstMux(t *testing.T) {
	t.Parallel()

	mux := http.NewServeMux()
	handlers.RegisterWorkflowCallbacks(mux, handlers.Businesses{})

	requests := collectWorkflowRequests(t)
	if len(requests) == 0 {
		t.Fatal("no http.request steps found in the workflow definitions")
	}

	for _, req := range requests {
		t.Run(req.method+" "+req.path, func(t *testing.T) {
			t.Parallel()

			httpReq := httptest.NewRequest(req.method, req.path, nil)
			_, pattern := mux.Handler(httpReq)
			if pattern == "" {
				t.Fatalf("workflow %s calls %s %s, which no registered route serves",
					req.workflow, req.method, req.path)
			}
		})
	}
}

type workflowRequest struct {
	workflow string
	method   string
	path     string
}

func collectWorkflowRequests(t *testing.T) []workflowRequest {
	t.Helper()

	entries, err := os.ReadDir(workflowsDir)
	if err != nil {
		t.Fatalf("read workflows dir: %v", err)
	}

	var requests []workflowRequest
	for _, entry := range entries {
		if entry.IsDir() || filepath.Ext(entry.Name()) != ".json" {
			continue
		}
		raw, readErr := os.ReadFile(filepath.Join(workflowsDir, entry.Name()))
		if readErr != nil {
			t.Fatalf("read %s: %v", entry.Name(), readErr)
		}

		var doc any
		if unmarshalErr := json.Unmarshal(raw, &doc); unmarshalErr != nil {
			t.Fatalf("parse %s: %v", entry.Name(), unmarshalErr)
		}
		requests = append(requests, walkForRequests(entry.Name(), doc)...)
	}
	return requests
}

func walkForRequests(workflow string, node any) []workflowRequest {
	switch typed := node.(type) {
	case map[string]any:
		var found []workflowRequest
		if req, ok := requestFromNode(workflow, typed); ok {
			found = append(found, req)
		}
		for _, v := range typed {
			found = append(found, walkForRequests(workflow, v)...)
		}
		return found
	case []any:
		var found []workflowRequest
		for _, v := range typed {
			found = append(found, walkForRequests(workflow, v)...)
		}
		return found
	default:
		return nil
	}
}

func requestFromNode(workflow string, node map[string]any) (workflowRequest, bool) {
	rawURL, hasURL := node["url"].(string)
	method, hasMethod := node["method"].(string)
	if !hasURL || !hasMethod {
		return workflowRequest{}, false
	}

	path := resolveTemplatePath(rawURL)
	if path == "" {
		return workflowRequest{}, false
	}
	return workflowRequest{workflow: workflow, method: strings.ToUpper(method), path: path}, true
}

// resolveTemplatePath turns a workflow URL template into a concrete request
// path: the service base is stripped and every interpolation becomes a stand-in
// path segment.
func resolveTemplatePath(rawURL string) string {
	resolved := templateExpr.ReplaceAllString(rawURL, "x")
	idx := strings.Index(resolved, "/api/")
	if idx < 0 {
		return ""
	}
	return resolved[idx:]
}

// fakeLoanWindowBusiness answers the evaluate-loan-window callback with a
// canned result or error, so the HTTP mapping can be exercised without a
// database.
type fakeLoanWindowBusiness struct {
	result map[string]any
	err    error
}

func (f *fakeLoanWindowBusiness) Evaluate(_ context.Context, _ string) (map[string]any, error) {
	if f.err != nil {
		return nil, f.err
	}
	return f.result, nil
}

func (f *fakeLoanWindowBusiness) Open(_ context.Context, _ string) (*models.LoanWindow, error) {
	return nil, f.err
}

// TestWorkflowCallbackStatusCodes asserts the error contract with the
// workflow engine: permanent failures come back as 4xx with a stable code so
// the engine's retry policy stops, transient ones as 5xx so it retries, and
// no response echoes internal detail.
func TestWorkflowCallbackStatusCodes(t *testing.T) {
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
			err:        apperrors.ErrDataNotFound.Extend("group"),
			wantStatus: http.StatusNotFound,
			wantCode:   "not_found",
			wantBody:   "Requested data not found - group",
		},
		{
			name:       "authored conflict is 409",
			err:        apperrors.NewError(apperrors.Conflict, "group already has an active tenure"),
			wantStatus: http.StatusConflict,
			wantCode:   "conflict",
			wantBody:   "group already has an active tenure",
		},
		{
			name:       "authored invalid state transition is 422",
			err:        apperrors.NewError(apperrors.Unprocessable, "period is already closed"),
			wantStatus: http.StatusUnprocessableEntity,
			wantCode:   "unprocessable",
			wantBody:   "period is already closed",
		},
		{
			name:       "authored bad request is 400",
			err:        apperrors.NewError(apperrors.BadRequest, "offer_id is required"),
			wantStatus: http.StatusBadRequest,
			wantCode:   "invalid_request",
			wantBody:   "offer_id is required",
		},
		{
			name:       "wrapped authored error keeps its class",
			err:        fmt.Errorf("evaluate window: %w", apperrors.NewError(apperrors.Gone, "loan offer has expired")),
			wantStatus: http.StatusGone,
			wantCode:   "gone",
			wantBody:   "loan offer has expired",
		},
		{
			name:       "peer not-found is 404 without the peer message",
			err:        fmt.Errorf("group not found: %w", connect.NewError(connect.CodeNotFound, leaked)),
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
			name:       "peer already-exists is 409",
			err:        connect.NewError(connect.CodeAlreadyExists, leaked),
			wantStatus: http.StatusConflict,
			wantCode:   "conflict",
			wantBody:   "the record was changed by another request",
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
			err:        fmt.Errorf("loan window not found: %w", gorm.ErrRecordNotFound),
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
			err:        fmt.Errorf("ledger: %w", context.DeadlineExceeded),
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
			handlers.RegisterWorkflowCallbacks(mux, handlers.Businesses{
				LoanWindow: &fakeLoanWindowBusiness{err: tt.err},
			})

			rec := httptest.NewRecorder()
			mux.ServeHTTP(rec, httptest.NewRequest(http.MethodPost, "/api/v1/groups/g-1/evaluate-loan-window", nil))

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
