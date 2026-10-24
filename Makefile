# Service-specific configuration
SERVICE_NAME := fintech
APP_DIRS     := $(sort $(patsubst %/,%,$(dir $(wildcard apps/*/))))
HAS_UI       := true
UI_DIR       := ui/seed

# Production OAuth — passed to flutter build via --dart-define.
# There are deliberately NO defaults: a production web bundle must be built
# with explicit credentials, and `make ui-build-prod` fails when they are
# missing rather than silently shipping a development client.
OIDC_CLIENT_ID_PROD ?=
OIDC_ISSUER_PROD    ?=
API_BASE_URL_PROD   ?=

# Bootstrap: download the shared Makefile.common, pinned to an immutable
# commit. The filename carries the ref so bumping COMMON_REF re-downloads
# instead of silently reusing a stale cache.
COMMON_REF ?= 0b3d2df096df7fb7bff3e91a8dcb12e0094b1a04
COMMON_MK  := .tmp/Makefile.common-$(COMMON_REF)

ifeq (,$(wildcard $(COMMON_MK)))
  $(shell mkdir -p .tmp && curl -sSfL https://raw.githubusercontent.com/antinvestor/common/$(COMMON_REF)/Makefile.common -o $(COMMON_MK))
endif

include $(COMMON_MK)

# Override the shared `test` target (which omits -race for a historical frame
# queue shutdown race that no longer reproduces on the pinned frame, see
# docs/runbook/race-detector.md). -p 1 keeps testcontainers-backed packages
# sequential. make warns about the override, as it does for ui-build-prod.
.PHONY: test
test: ## Run all tests with the race detector (sequential packages)
	$(GO) test -vet=off -race -cover -count=1 -p 1 ./...

# Dart proto modules — each gets its own buf.gen.dart.<module>.yaml so that
# generation is scoped to a single module and dart packages don't leak each
# other's types. See proto/buf.gen.dart.*.yaml.
DART_MODULES := identity field loans savings funding operations limits

.PHONY: proto-generate-dart
proto-generate-dart: $(BIN)/buf ## Regenerate the per-module dart SDKs
	@if [ ! -d "$(PROTO_DIR)" ]; then exit 0; fi
	@for pkg in $(DART_MODULES); do \
		for other in $(DART_MODULES); do \
			[ "$$pkg" = "$$other" ] && continue; \
			rm -rf sdk/dart/$$pkg/lib/src/$$other; \
		done; \
	done
	@for m in $(DART_MODULES); do \
		echo "==> dart $$m"; \
		(cd $(PROTO_DIR) && buf generate --template buf.gen.dart.$$m.yaml $$m); \
	done

# Wire dart generation into the standard proto-generate pipeline.
proto-generate: proto-generate-dart

# ------------------------------------------------------------------------------
# OPL (Keto namespaces)
# ------------------------------------------------------------------------------
# $(DEFAULT_APP) (apps/default) is the single source of truth for Keto OPL:
# `generate-opl` writes it and .github/workflows/release.yaml pushes it. Never
# hand-edit the .opl.ts files — change proto service_permissions and regenerate.

.PHONY: opl-generate
opl-generate: $(BIN)/buf $(BIN)/generate-opl $(BIN)/license-header ## Regenerate Keto OPL from proto service_permissions
	@# seed and stawi are their own buf workspaces; each manifest is built.
	@for ws in $(PROTO_DIR) $(PROTO_DIR)/seed $(PROTO_DIR)/stawi; do \
		buf build $$ws -o /dev/stdout | $(BIN)/generate-opl $(DEFAULT_APP) || exit 1; \
	done
	@# generate-opl emits bare files; proto-generate adds the headers afterwards,
	@# so this target must too or the drift check reports a false positive.
	@$(BIN)/license-header \
		--license-type apache \
		--copyright-holder "$(COPYRIGHT_HOLDER)" \
		--year-range "$(COPYRIGHT_YEARS)" \
		$(DEFAULT_APP)/*.opl.ts

.PHONY: opl-check
opl-check: opl-generate ## Fail if the committed OPL differs from the generator output
	@git diff --exit-code -- $(DEFAULT_APP) || { \
		echo "::error::$(DEFAULT_APP) is out of date; run 'make opl-generate' and commit the result"; \
		exit 1; \
	}

# Override prod build to inject this service's production credentials
.PHONY: ui-build-prod
ui-build-prod: ui-generate ## Build Flutter web (production — requires OIDC/API env)
	@missing=""; \
	[ -n "$(OIDC_CLIENT_ID_PROD)" ] || missing="$$missing OIDC_CLIENT_ID_PROD"; \
	[ -n "$(OIDC_ISSUER_PROD)" ]    || missing="$$missing OIDC_ISSUER_PROD"; \
	[ -n "$(API_BASE_URL_PROD)" ]   || missing="$$missing API_BASE_URL_PROD"; \
	if [ -n "$$missing" ]; then \
		echo "ui-build-prod: refusing to build, unset:$$missing"; \
		exit 1; \
	fi
	cd $(UI_DIR) && "$(FLUTTER)" build web \
		--release \
		--base-href="/" \
		--tree-shake-icons \
		--no-web-resources-cdn \
		--dart-define=OIDC_CLIENT_ID=$(OIDC_CLIENT_ID_PROD) \
		--dart-define=OIDC_ISSUER=$(OIDC_ISSUER_PROD) \
		--dart-define=API_BASE_URL=$(API_BASE_URL_PROD)
	@echo "Production build: $(UI_DIR)/build/web/"
