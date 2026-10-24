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

// Package authz holds the Keto namespace names this service checks against.
// Permissions and the roles that carry them are declared in
// savings.proto's service_permissions and generated into
// service_savings.opl.ts; they are never restated in Go.
package authz

const (
	NamespaceLenderSavings = "service_savings"
	NamespaceTenancyAccess = "tenancy_access"
	NamespaceProfile       = "profile_user"
)
