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

// Package bootcheck refuses to start a service whose environment would make
// it unsafe in a shared deployment. The rules are the ones documented in
// docs/runbook/required-environment.md; this package makes the services
// enforce them instead of relying on every deployment remembering to.
package bootcheck

import (
	"context"
	"errors"
	"fmt"
	"strings"

	"github.com/pitabwire/frame/v3"
	"github.com/pitabwire/util"
)

// Config is the slice of frame's configuration the guard reads. Every
// config in this repo embeds config.ConfigurationDefault and satisfies it.
type Config interface {
	IsRunSecurely() bool
	GetQueuePushAuth() string
	GetEventsQueueURL() string
	GetDatabaseMigrationPath() string
}

// ErrUnsafeEnvironment wraps every violation found in a secure deployment.
var ErrUnsafeEnvironment = errors.New("refusing to start: unsafe environment")

const memQueueScheme = "mem://"

// Violations lists every rule the configuration breaks, in a fixed order,
// or nil when the environment is deployment-safe.
//
// A setup Job (frame.ShouldRunSetup: argv setup, DO_SETUP or DO_MIGRATION)
// runs migrations and registrations and exits; it never consumes queued
// events, and deployments give it an in-memory queue with no push auth on
// purpose. The queue rules therefore apply only to the serving process.
func Violations(cfg Config) []string {
	var out []string
	if !cfg.IsRunSecurely() {
		out = append(out, "RUN_SERVICE_SECURELY must be true")
	}
	if !frame.ShouldRunSetup(cfg) {
		out = append(out, queueViolations(cfg)...)
	}
	if strings.TrimSpace(cfg.GetDatabaseMigrationPath()) == "" {
		out = append(out, "MIGRATION_PATH must be set")
	}
	return out
}

func queueViolations(cfg Config) []string {
	var out []string
	switch strings.ToLower(strings.TrimSpace(cfg.GetQueuePushAuth())) {
	case "oidc", "bearer":
	default:
		out = append(out, fmt.Sprintf(
			"FRAME_QUEUE_PUSH_AUTH must be oidc or bearer, got %q", cfg.GetQueuePushAuth()))
	}
	if url := strings.TrimSpace(cfg.GetEventsQueueURL()); url == "" || strings.HasPrefix(url, memQueueScheme) {
		out = append(out, fmt.Sprintf(
			"EVENTS_QUEUE_URL must point at a durable broker, got %q", cfg.GetEventsQueueURL()))
	}
	return out
}

// Validate applies the rules before the service initialises. When the
// service runs securely every violation is fatal and reported together in
// one error; otherwise each violation is logged as a warning and nil is
// returned so local development keeps working on frame's defaults.
func Validate(ctx context.Context, cfg Config) error {
	violations := Violations(cfg)
	if len(violations) == 0 {
		return nil
	}
	if cfg.IsRunSecurely() {
		return fmt.Errorf("%w: %s", ErrUnsafeEnvironment, strings.Join(violations, "; "))
	}
	log := util.Log(ctx)
	for _, v := range violations {
		log.Warn("bootcheck: " + v + " (tolerated because RUN_SERVICE_SECURELY=false)")
	}
	return nil
}
