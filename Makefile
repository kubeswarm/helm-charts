# helm-charts Makefile
# Run `make help` for all available targets.

SHELL = /usr/bin/env bash -o pipefail
.SHELLFLAGS = -ec

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

.PHONY: ci
ci: lint ## Run the full CI pipeline locally.
	@echo "CI passed."
