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

package clients

import (
	"context"
	"errors"
	"fmt"
	"net/http"

	"buf.build/gen/go/antinvestor/audit/connectrpc/go/audit/v1/auditv1connect"
	"connectrpc.com/connect"
	"github.com/antinvestor/common/audit"
	"github.com/antinvestor/common/v2"
	"github.com/antinvestor/common/v2/connection"
	"github.com/antinvestor/common/v2/servicecatalog"
	"github.com/pitabwire/util"
)

// AuditConfig is the audit service endpoint every service config embeds.
// The URI has no default on purpose: a secure deployment that forgets to set
// it must fail at boot rather than silently drop its RPC-level audit trail.
type AuditConfig struct {
	AuditServiceURI                   string `envDefault:""                           env:"AUDIT_SERVICE_URI"`
	AuditServiceWorkloadAPITargetPath string `envDefault:"/ns/audit/sa/service-audit" env:"AUDIT_SERVICE_WORKLOAD_API_TARGET_PATH"`
}

// ErrAuditServiceRequired is returned when a securely running service has no
// audit endpoint configured.
var ErrAuditServiceRequired = errors.New("AUDIT_SERVICE_URI is required when RUN_SERVICE_SECURELY=true")

// NewAuditClient builds the audit service client through the same platform
// client path as tenancy and identity, so it inherits the workload-identity
// transport and the repo's standard 30s client-level timeout.
func NewAuditClient(ctx context.Context, cfg any, target AuditConfig) (auditv1connect.AuditServiceClient, error) {
	return connection.NewServiceClient(ctx, cfg, common.ServiceTarget{
		Endpoint:              target.AuditServiceURI,
		WorkloadAPITargetPath: target.AuditServiceWorkloadAPITargetPath,
		ServiceID:             servicecatalog.ServiceAudit,
	}, audit.NewConnectClient)
}

// ResolveAuditClient applies the boot policy for the audit client: with an
// endpoint it returns a client; without one it fails when the service runs
// securely and otherwise warns and returns nil, which makes the audit
// interceptor a no-op for local development.
func ResolveAuditClient(
	ctx context.Context, cfg any, runSecurely bool, target AuditConfig,
) (auditv1connect.AuditServiceClient, error) {
	if target.AuditServiceURI == "" {
		if runSecurely {
			return nil, ErrAuditServiceRequired
		}
		util.Log(ctx).Warn("audit service URI is empty; RPC-level audit is disabled (RUN_SERVICE_SECURELY=false)")
		return nil, nil //nolint:nilnil // nil client is the documented "audit disabled" state for insecure runs
	}
	cli, err := NewAuditClient(ctx, cfg, target)
	if err != nil {
		return nil, fmt.Errorf("audit client: %w", err)
	}
	return cli, nil
}

// AuditInterceptor returns the RPC-level audit interceptor for serviceName
// backed by the resolved client (nil disables delivery).
func AuditInterceptor(serviceName string, cli auditv1connect.AuditServiceClient) connect.Interceptor {
	return audit.NewInterceptor(serviceName, cli)
}

// AuditHTTPMiddleware is the http.Handler form of AuditInterceptor for the
// services that expose plain HTTP routes. Mount it after authentication so
// the actor is taken from claims:
//
//	handler = clients.AuditHTTPMiddleware("service_stawi", auditCli)(mux)
func AuditHTTPMiddleware(serviceName string, cli auditv1connect.AuditServiceClient) func(http.Handler) http.Handler {
	return audit.HTTPMiddleware(serviceName, cli)
}
