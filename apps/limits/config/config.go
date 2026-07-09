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
)

// LimitsConfig drives the limits service. Defaults are conservative.
type LimitsConfig struct {
	config.ConfigurationDefault

	// PolicyCacheTTLSeconds bounds how long policy lookups live in the
	// in-process LRU. 60s matches the spec; tuned via env in production.
	PolicyCacheTTLSeconds int `envDefault:"60" env:"POLICY_CACHE_TTL_SECONDS"`

	// SubjectAttributeCacheTTLSeconds same idea for subject attributes.
	SubjectAttributeCacheTTLSeconds int `envDefault:"60" env:"SUBJECT_ATTRIBUTE_CACHE_TTL_SECONDS"`
}
