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

package e2e_test

import (
	"context"
	_ "embed"
	"fmt"
	"maps"
	"net/url"
	"os"
	"path/filepath"
	"regexp"
	"slices"
	"strings"

	"github.com/pitabwire/frame/v3/config"
	"github.com/pitabwire/frame/v3/frametests/definition"
	"github.com/pitabwire/frame/v3/frametests/deps/testoryketo"
	"github.com/pitabwire/frame/v3/security"
	"github.com/pitabwire/frame/v3/security/authorizer"
)

// The suite authorizes against a real Ory Keto, as deployed: the image and
// configuration of cloud.deployment apps/identity-authorization-keto
// (cloudrun/envs/stawi-prod.tfvars, files/keto.yml), with an in-memory store
// in place of the production database.
const (
	ketoImage = "oryd/keto:v0.12.0"

	ketoNamespacesPath = "/etc/keto-namespaces/namespaces.ts"

	ketoConfiguration = `
version: v0.12.0

dsn: memory

serve:
  read:
    host: 0.0.0.0
    port: 4466
  write:
    host: 0.0.0.0
    port: 4467

namespaces:
  location: file://` + ketoNamespacesPath + `

log:
  level: warn
  format: text
`

	// fintechOPLDir holds the OPL this repository generates from proto
	// service_permissions and the release pushes into the merged file.
	fintechOPLDir = "../../apps/default"
)

// productionNamespaces is cloud.deployment's
// apps/identity-authorization-keto/files/namespaces.ts: every namespace of
// the platform, merged. Refresh it by copying that file.
//
//go:embed testdata/keto/namespaces.ts
var productionNamespaces string

var oplClass = regexp.MustCompile(`(?ms)^class (\w+) implements Namespace \{.*?^\}\n`)

// ketoNamespaces is the production OPL with this repository's own
// namespaces (service_loans, service_operations, ...) replaced by what
// `make opl-generate` produces now. The release pushes those, so a change
// to proto service_permissions is checked here before it ships, and the
// rest of the platform's model (tenancy_access, profile_user, other
// services) stays as deployed.
func ketoNamespaces() (string, error) {
	generated, err := filepath.Glob(filepath.Join(fintechOPLDir, "*.opl.ts"))
	if err != nil {
		return "", err
	}
	if len(generated) == 0 {
		return "", fmt.Errorf("no generated OPL under %s", fintechOPLDir)
	}

	own := map[string]string{}
	for _, path := range generated {
		content, readErr := os.ReadFile(path)
		if readErr != nil {
			return "", readErr
		}
		for _, m := range oplClass.FindAllStringSubmatch(string(content), -1) {
			// Each generated file repeats the shared base namespaces; the
			// merged file's copies are the deployed ones.
			if m[1] == security.NamespaceProfile || m[1] == "tenancy_access" {
				continue
			}
			own[m[1]] = m[0]
		}
	}

	replaced := map[string]bool{}
	merged := oplClass.ReplaceAllStringFunc(productionNamespaces, func(class string) string {
		name := oplClass.FindStringSubmatch(class)[1]
		if body, ok := own[name]; ok {
			replaced[name] = true
			return body
		}
		return class
	})
	// A namespace not deployed yet is added, as the release would.
	var out strings.Builder
	out.WriteString(merged)
	for _, name := range slices.Sorted(maps.Keys(own)) {
		if !replaced[name] {
			out.WriteString("\n" + own[name])
		}
	}
	return out.String(), nil
}

// newKetoResource is the Keto container, through frame's own test helper.
func newKetoResource(namespaces string) definition.TestResource {
	return testoryketo.NewWithNamespaces(
		ketoConfiguration,
		[]testoryketo.NamespaceFile{{ContainerPath: ketoNamespacesPath, Content: namespaces}},
		definition.WithImageName(ketoImage),
		definition.WithEnableLogging(false),
	)
}

// newKetoAuthorizer is frame's Keto adapter in enforced mode, as
// security/manager builds it for a service whose AUTHORIZATION_SERVICE_*_URI
// point at Keto: every tenancy and per-RPC check is a real Keto check.
func newKetoAuthorizer(ctx context.Context, keto definition.DependancyConn) (security.Authorizer, error) {
	write, err := url.Parse(string(keto.GetDS(ctx)))
	if err != nil {
		return nil, fmt.Errorf("keto write endpoint: %w", err)
	}
	readPort, err := keto.PortMapping(ctx, "4466/tcp")
	if err != nil {
		return nil, fmt.Errorf("keto read endpoint: %w", err)
	}
	cfg := &config.ConfigurationDefault{
		AuthorizationMode:            config.AuthorizationModeEnforced,
		AuthorizationServiceReadURI:  fmt.Sprintf("%s:%s", write.Hostname(), readPort),
		AuthorizationServiceWriteURI: write.Host,
	}
	return authorizer.NewKetoAdapter(cfg, nil), nil
}
