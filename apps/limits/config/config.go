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

package config

import (
	"github.com/pitabwire/frame/v2/config"

	"github.com/antinvestor/service-fintech/pkg/clients"
)

// LimitsConfig drives the limits service. Defaults are conservative.
type LimitsConfig struct {
	config.ConfigurationDefault
	clients.AuditConfig

	// PolicyCacheTTLSeconds bounds how long policy lookups live in the
	// in-process LRU. 60s matches the spec; tuned via env in production.
	PolicyCacheTTLSeconds int `envDefault:"60" env:"POLICY_CACHE_TTL_SECONDS"`

	// SubjectAttributeCacheTTLSeconds same idea for subject attributes.
	SubjectAttributeCacheTTLSeconds int `envDefault:"60" env:"SUBJECT_ATTRIBUTE_CACHE_TTL_SECONDS"`

	// Identity service — resolves subject attributes (KYC tier, country) that
	// attribute-filtered policies match on.
	IdentityServiceURI                   string `envDefault:"127.0.0.1:7001"                  env:"IDENTITY_SERVICE_URI"`
	IdentityServiceWorkloadAPITargetPath string `envDefault:"/ns/fintech/sa/service-identity" env:"IDENTITY_SERVICE_WORKLOAD_API_TARGET_PATH"`

	// Tenancy service — resolves a partition's ancestors. Policies are tiered
	// along the partition tree: a policy set on any ancestor of the
	// transaction's partition applies to it.
	TenancyServiceURI                   string `envDefault:"127.0.0.1:7003"              env:"TENANCY_SERVICE_URI"`
	TenancyServiceWorkloadAPITargetPath string `envDefault:"/ns/auth/sa/service-tenancy" env:"TENANCY_SERVICE_WORKLOAD_API_TARGET_PATH"`
	// PartitionChainCacheTTLSeconds bounds how long a resolved partition
	// chain is reused; the tree changes only when partitions are created.
	PartitionChainCacheTTLSeconds int `envDefault:"300" env:"PARTITION_CHAIN_CACHE_TTL_SECONDS"`

	// ArchivalReservationRetentionHours bounds how long terminal reservations
	// are kept before the archival job hard-deletes them.
	ArchivalReservationRetentionHours int `envDefault:"168" env:"ARCHIVAL_RESERVATION_RETENTION_HOURS"`

	// ArchivalLedgerRetentionHours bounds how long committed ledger entries are
	// kept. The job widens this automatically so it never deletes inside the
	// widest live rolling window.
	ArchivalLedgerRetentionHours int `envDefault:"2160" env:"ARCHIVAL_LEDGER_RETENTION_HOURS"`
}
