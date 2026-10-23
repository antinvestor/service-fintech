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
	"encoding/json"
	"net/http"

	"github.com/pitabwire/frame/v2/security"
	"github.com/pitabwire/util"
)

// ArchivalRunner is the subset of business.Archival used by ArchivalHandler.
// The interface makes the handler testable without a database.
type ArchivalRunner interface {
	Run(ctx context.Context) (resvDeleted, ledgerDeleted int, err error)
}

// ArchivalHandler serves POST /admin/archive. It hard-deletes terminal
// reservations and old ledger entries via the Archival business job.
type ArchivalHandler struct {
	archival ArchivalRunner
}

// NewArchivalHandler constructs the handler. archival is usually *business.Archival;
// any ArchivalRunner implementation is accepted to keep the handler testable.
func NewArchivalHandler(archival ArchivalRunner) *ArchivalHandler {
	return &ArchivalHandler{archival: archival}
}

// ServeHTTP implements http.Handler.
//
// Archival hard-deletes rows across every tenant, so beyond the route's
// function-access permission the caller must be a machine principal: an
// ordinary operator token, however privileged inside its own tenant, must not
// be able to destroy another tenant's ledger.
func (h *ArchivalHandler) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Error(w, "method not allowed", http.StatusMethodNotAllowed)
		return
	}
	if !isServiceAccount(r.Context()) {
		util.Log(r.Context()).Warn("archival: rejected non-service principal")
		http.Error(w, "archival requires a service-account principal", http.StatusForbidden)
		return
	}
	resvN, ledgerN, err := h.archival.Run(r.Context())
	if err != nil {
		util.Log(r.Context()).WithError(err).Error("archival run failed")
		http.Error(w, "archival failed", http.StatusInternalServerError)
		return
	}
	w.Header().Set("Content-Type", "application/json")
	_ = json.NewEncoder(w).Encode(map[string]int{
		"reservations_deleted": resvN,
		"ledger_deleted":       ledgerN,
	})
}

// isServiceAccount reports whether the caller's claims belong to a machine
// principal (internal-system role or a service token), as required by
// apps/limits/docs/runbook/archival-trustage.md.
func isServiceAccount(ctx context.Context) bool {
	claims := security.ClaimsFromContext(ctx)
	if claims == nil {
		return false
	}
	return claims.IsInternalSystem() || claims.GetServiceName() != ""
}
