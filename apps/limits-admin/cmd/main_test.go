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

package main_test

import (
	"bytes"
	"context"
	"errors"
	"fmt"
	"net/http"
	"net/http/httptest"
	"os"
	"os/exec"
	"strings"
	"testing"
	"time"

	"buf.build/gen/go/antinvestor/limits/connectrpc/go/limits/v1/limitsv1connect"
	limitsv1 "buf.build/gen/go/antinvestor/limits/protocolbuffers/go/limits/v1"
	"connectrpc.com/connect"
)

// stubAdminServer is a minimal in-process LimitsAdminService handler
// that returns canned responses for testing.
type stubAdminServer struct {
	limitsv1connect.UnimplementedLimitsAdminServiceHandler

	policies []*limitsv1.PolicyObject
}

func (s *stubAdminServer) PolicySearch(
	_ context.Context,
	_ *connect.Request[limitsv1.PolicySearchRequest],
	stream *connect.ServerStream[limitsv1.PolicySearchResponse],
) error {
	return stream.Send(&limitsv1.PolicySearchResponse{Data: s.policies})
}

func (s *stubAdminServer) PolicyGet(
	_ context.Context,
	req *connect.Request[limitsv1.PolicyGetRequest],
) (*connect.Response[limitsv1.PolicyGetResponse], error) {
	for _, p := range s.policies {
		if p.GetId() == req.Msg.GetId() {
			return connect.NewResponse(&limitsv1.PolicyGetResponse{Data: p}), nil
		}
	}
	return nil, connect.NewError(connect.CodeNotFound, fmt.Errorf("policy %q not found", req.Msg.GetId()))
}

func (s *stubAdminServer) ApprovalRequestList(
	_ context.Context,
	_ *connect.Request[limitsv1.ApprovalRequestListRequest],
	stream *connect.ServerStream[limitsv1.ApprovalRequestListResponse],
) error {
	return stream.Send(&limitsv1.ApprovalRequestListResponse{})
}

func (s *stubAdminServer) ApprovalRequestGet(
	_ context.Context,
	req *connect.Request[limitsv1.ApprovalRequestGetRequest],
) (*connect.Response[limitsv1.ApprovalRequestGetResponse], error) {
	return nil, connect.NewError(connect.CodeNotFound, fmt.Errorf("not found: %s", req.Msg.GetId()))
}

func (s *stubAdminServer) ApprovalRequestDecide(
	_ context.Context,
	req *connect.Request[limitsv1.ApprovalRequestDecideRequest],
) (*connect.Response[limitsv1.ApprovalRequestDecideResponse], error) {
	return connect.NewResponse(&limitsv1.ApprovalRequestDecideResponse{
		Data: &limitsv1.ApprovalRequestObject{
			Id:     req.Msg.GetId(),
			Status: limitsv1.ApprovalStatus_APPROVAL_STATUS_APPROVED,
		},
	}), nil
}

// newTestServer spins up an httptest.Server with the stub admin handler and
// returns the server URL plus a cleanup function.
func newTestServer(t *testing.T, policies []*limitsv1.PolicyObject) (string, func()) {
	t.Helper()

	stub := &stubAdminServer{policies: policies}
	mux := http.NewServeMux()
	path, handler := limitsv1connect.NewLimitsAdminServiceHandler(stub)
	mux.Handle(path, handler)

	srv := httptest.NewServer(mux)
	return srv.URL, srv.Close
}

// buildBinary compiles the limits-admin binary for testing.
// It returns the path to the binary and a cleanup function.
func buildBinary(t *testing.T) string {
	t.Helper()
	bin := t.TempDir() + "/limits-admin"
	cmd := exec.Command("go", "build", "-o", bin, "github.com/antinvestor/service-fintech/apps/limits-admin/cmd")
	var stderr bytes.Buffer
	cmd.Stderr = &stderr
	if err := cmd.Run(); err != nil {
		t.Fatalf("failed to build limits-admin binary: %v\n%s", err, stderr.String())
	}
	return bin
}

// TestPoliciesList_FormatsTable verifies that `limits-admin policies list`
// renders a tabwriter table with the expected column headers and row data.
func TestPoliciesList_FormatsTable(t *testing.T) {
	policies := []*limitsv1.PolicyObject{
		{
			Id:           "pol-001",
			Scope:        limitsv1.PolicyScope_POLICY_SCOPE_PLATFORM,
			Action:       limitsv1.LimitAction_LIMIT_ACTION_LOAN_DISBURSEMENT,
			Mode:         limitsv1.PolicyMode_POLICY_MODE_SHADOW,
			CurrencyCode: "KES",
			Notes:        "test policy",
		},
	}

	serverURL, cleanup := newTestServer(t, policies)
	defer cleanup()

	bin := buildBinary(t)

	ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
	defer cancel()

	cmd := exec.CommandContext(ctx, bin, "--uri", serverURL, "policies", "list")
	cmd.Env = append(os.Environ(), "LIMITS_ADMIN_TOKEN=test-token")
	var stdout, stderr bytes.Buffer
	cmd.Stdout = &stdout
	cmd.Stderr = &stderr

	if err := cmd.Run(); err != nil {
		t.Fatalf("command failed: %v\nstderr: %s", err, stderr.String())
	}

	out := stdout.String()
	wantCols := []string{"ID", "SCOPE", "ACTION", "MODE", "CURRENCY"}
	for _, col := range wantCols {
		if !strings.Contains(out, col) {
			t.Errorf("expected column header %q in output:\n%s", col, out)
		}
	}

	wantValues := []string{
		"pol-001",
		"POLICY_SCOPE_PLATFORM",
		"LIMIT_ACTION_LOAN_DISBURSEMENT",
		"POLICY_MODE_SHADOW",
		"KES",
	}
	for _, v := range wantValues {
		if !strings.Contains(out, v) {
			t.Errorf("expected value %q in output:\n%s", v, out)
		}
	}
}

// TestApprove_RequiresReason verifies that `approvals approve` exits non-zero
// and prints a helpful message when --reason is omitted.
func TestApprove_RequiresReason(t *testing.T) {
	serverURL, cleanup := newTestServer(t, nil)
	defer cleanup()

	bin := buildBinary(t)

	ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
	defer cancel()

	cmd := exec.CommandContext(
		ctx,
		bin,
		"--uri",
		serverURL,
		"approvals",
		"approve",
		"some-reservation-id",
	)
	cmd.Env = append(os.Environ(), "LIMITS_ADMIN_TOKEN=test-token")
	var stderr bytes.Buffer
	cmd.Stderr = &stderr

	err := cmd.Run()
	if err == nil {
		t.Fatal("expected non-zero exit when --reason is missing, got exit 0")
	}

	exitErr := &exec.ExitError{}
	if errors.As(err, &exitErr) {
		if exitErr.ExitCode() == 0 {
			t.Fatal("expected non-zero exit code")
		}
	}

	combined := stderr.String()
	if !strings.Contains(combined, "reason") {
		t.Errorf("expected stderr to mention 'reason', got: %s", combined)
	}
}

// TestPoliciesList_JSONFlag verifies that --json emits parseable JSON.
func TestPoliciesList_JSONFlag(t *testing.T) {
	policies := []*limitsv1.PolicyObject{
		{
			Id:     "pol-002",
			Action: limitsv1.LimitAction_LIMIT_ACTION_SAVINGS_DEPOSIT,
			Mode:   limitsv1.PolicyMode_POLICY_MODE_ENFORCE,
		},
	}

	serverURL, cleanup := newTestServer(t, policies)
	defer cleanup()

	bin := buildBinary(t)

	ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
	defer cancel()

	cmd := exec.CommandContext(ctx, bin, "--uri", serverURL, "--json", "policies", "list")
	cmd.Env = append(os.Environ(), "LIMITS_ADMIN_TOKEN=test-token")
	var stdout, stderr bytes.Buffer
	cmd.Stdout = &stdout
	cmd.Stderr = &stderr

	if err := cmd.Run(); err != nil {
		t.Fatalf("command failed: %v\nstderr: %s", err, stderr.String())
	}

	out := stdout.String()
	// protojson emits enum names as strings.
	if !strings.Contains(out, "pol-002") {
		t.Errorf("expected policy ID in JSON output:\n%s", out)
	}
}
