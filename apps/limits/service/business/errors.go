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

package business

import "errors"

var (
	ErrPolicyNotFound       = errors.New("limits: policy not found")
	ErrInvalidPolicy        = errors.New("limits: invalid policy")
	ErrCurrencyMismatch     = errors.New("limits: cap amount currency does not match policy currency")
	ErrApproverTiersInvalid = errors.New("limits: approver_tiers misconfigured")
	// ErrPolicyVersionConflict is returned when the version the caller edited
	// is no longer the stored one — another operator saved in between.
	ErrPolicyVersionConflict = errors.New("limits: policy version conflict")
	// ErrPolicyScopeForbidden is returned when a caller without platform
	// authority tries to create or edit a platform-scoped policy.
	ErrPolicyScopeForbidden = errors.New("limits: platform scope not permitted for this caller")
)
