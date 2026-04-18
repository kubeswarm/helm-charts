# helm-charts Makefile
# Run `make help` for all available targets.

SHELL = /usr/bin/env bash -o pipefail
.SHELLFLAGS = -ec

# Location of the operator repo's generated CRDs. Override if your checkout layout differs.
OPERATOR_CRD_DIR ?= ../kubeswarm/config/crd/bases
CHART_CRD_DIR    := charts/kubeswarm/templates/crds

.PHONY: help
help: ## Show this help.
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z_0-9-]+:.*?##/ { printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

.PHONY: setup
setup: ## One-time dev setup: install git hooks.
	@ln -sf ../../scripts/commit-msg .git/hooks/commit-msg
	@ln -sf ../../scripts/pre-push .git/hooks/pre-push
	@echo "Installed git hooks (commit-msg, pre-push)."

.PHONY: lint
lint: ## Lint all charts.
	@for chart in charts/*/; do \
		echo "-- lint: $$chart"; \
		helm lint "$$chart"; \
	done

.PHONY: template
template: ## Render templates locally (dry-run).
	@helm template kubeswarm charts/kubeswarm --namespace kubeswarm-system

.PHONY: sync-crds
sync-crds: ## Copy CRDs from operator repo, wrap with crds.install toggle, inject keep annotation.
	@if [ ! -d "$(OPERATOR_CRD_DIR)" ]; then \
		echo "error: $(OPERATOR_CRD_DIR) not found. Set OPERATOR_CRD_DIR=<path/to/operator/config/crd/bases>"; \
		exit 1; \
	fi
	@mkdir -p $(CHART_CRD_DIR)
	@rm -f $(CHART_CRD_DIR)/kubeswarm.io_*.yaml
	@for src in $(OPERATOR_CRD_DIR)/kubeswarm.io_*.yaml; do \
		dst="$(CHART_CRD_DIR)/$$(basename $$src)"; \
		{ \
			echo '{{- if .Values.crds.install }}'; \
			awk 'BEGIN { done=0 } \
			     { gsub(/\{\{/, "__KSW_OPEN__"); \
			       gsub(/\}\}/, "__KSW_CLOSE__"); \
			       gsub(/__KSW_OPEN__/, "{{`{{`}}"); \
			       gsub(/__KSW_CLOSE__/, "{{`}}`}}") } \
			     /^  annotations:$$/ && !done { print; print "    helm.sh/resource-policy: keep"; done=1; next } \
			     { print }' "$$src"; \
			echo '{{- end }}'; \
		} > "$$dst"; \
		echo "synced: $$(basename $$dst)"; \
	done

.PHONY: ci
ci: lint ## Run the full CI pipeline locally.
	@echo "CI passed."
