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

type IdentityConfig struct {
	config.ConfigurationDefault
	ProfileServiceURI                   string `envDefault:"127.0.0.1:7005"                 env:"PROFILE_SERVICE_URI"`
	TenancyServiceURI                   string `envDefault:"127.0.0.1:7003"                 env:"TENANCY_SERVICE_URI"`
	ProfileServiceWorkloadAPITargetPath string `envDefault:"/ns/profile/sa/service-profile" env:"PROFILE_SERVICE_WORKLOAD_API_TARGET_PATH"`
	TenancyServiceWorkloadAPITargetPath string `envDefault:"/ns/auth/sa/service-tenancy"    env:"TENANCY_SERVICE_WORKLOAD_API_TARGET_PATH"`

	NotificationServiceURI                   string `envDefault:"127.0.0.1:7040"                           env:"NOTIFICATION_SERVICE_URI"`
	NotificationServiceWorkloadAPITargetPath string `envDefault:"/ns/notification/sa/service-notification" env:"NOTIFICATION_SERVICE_WORKLOAD_API_TARGET_PATH"`
	AgentOnboardingTemplate                  string `envDefault:"template.fintech.agent.onboarding"        env:"AGENT_ONBOARDING_TEMPLATE"`

	MaxAgentDepth int `envDefault:"5" env:"MAX_AGENT_DEPTH"`

	// OAuthRedirectURIs are the allowed redirect URIs for partition-scoped OAuth clients.
	OAuthRedirectURIs string `envDefault:"http://localhost:5174/auth/callback,com.antinvestor.app://auth/callback" env:"OAUTH_REDIRECT_URIS"`

	// OAuthAudiences are the service audiences that partition-scoped OAuth clients can access.
	OAuthAudiences string `envDefault:"service_identity,service_field" env:"OAUTH_AUDIENCES"`
}
