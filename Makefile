.EXPORT_ALL_VARIABLES:

# skopeo list-tags --no-creds docker://helmunittest/helm-unittest
DOCKER_HELM_UNITITEST_IMAGE := helmunittest/helm-unittest:3.13.3-0.4.0

SUPPORTED := chart issue-337

check-issue: # export folder=chart
ifeq ($(filter $(folder),$(SUPPORTED)),)
	$(error $(folder) is not supported. Supported: $(SUPPORTED))
endif

help:
	@grep -E '^[a-zA-Z0-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

hooks: ## install pre commit.
	@pre-commit install
	@pre-commit gc
	@pre-commit autoupdate

install: ## Install pre-commit hooks.
	@pre-commit install
	@pre-commit gc

uninstall: ## Uninstall hooks.
	@pre-commit uninstall

validate: ## Validate files with pre-commit hooks.
	@pre-commit run --all-files

template: ## Template helm chart for local testing.
	@helm template chart chart \
		--output-dir output -n default \
		-f chart/values.yaml

lint: ## Lint helm chart.
	helm lint chart --values chart/values.yaml --debug

unit-test-docker: check-issue ## Execute Unit tests via Container  -c "/bin/sh"
	$(info Running unit tests...)
	@docker run \
		-v $(shell pwd)/$(folder):/apps/\
		-it --rm  $(DOCKER_HELM_UNITITEST_IMAGE) -f tests/*.yaml .

unit-test-local: check-issue ## Execute Unit tests locally
	@helm unittest -f 'tests/*.yaml' $(folder)

test: unit-test ## Run all available tests
