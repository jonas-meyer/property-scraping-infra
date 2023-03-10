STAGE ?= development
TERRAFORM_VAR_CONTEXT := -var-file="./envs/$(STAGE)/enviroment_specific_vars_$(STAGE).tfvars" -var-file="./envs/$(STAGE)/terraform_backend_config_${STAGE}.tfvars"

TERRAFORM_ADD_ARGS ?=

export TF_DATA_DIR=$(shell pwd)/envs/$(STAGE)/.terraform
TERRAFORM_ARGS := ${TERRAFORM_ADD_ARGS} ${TERRAFORM_VAR_CONTEXT}

# detect run in CI because other backend config is required there
#ifeq ($(CI),true)
#	CI_SUFFIX ?= _ci
#endif

envs/$(STAGE)/.terraform: ## automatically initialize terraform
	terraform init -backend-config="./envs/$(STAGE)/terraform_backend_config_$(STAGE)$(CI_SUFFIX).tfvars" -reconfigure

upgrade-tf-dependencies: ## upgrade terraform provider and module versions to satisfy requirements
	terraform init -backend-config="./envs/$(STAGE)/terraform_backend_config_$(STAGE)$(CI_SUFFIX).tfvars" -upgrade=true
	terraform providers lock -platform=darwin_amd64 -platform=darwin_arm64 -platform=linux_amd64

terraform: ## run arbitrary terraform commands WITH parameters and vars; eg. 'make state mv terraform a.b a.c'
	terraform $(shell echo $(MAKECMDGOALS) | sed 's/$@.*$$//') ${TERRAFORM_ARGS} $(shell echo $(MAKECMDGOALS) | sed 's/^.* $@//')

terraform-without-vars: envs/$(STAGE)/.terraform ## run arbitrary terraform commands WITHOUT vars
	terraform $(filter-out $@,$(MAKECMDGOALS)) ${TERRAFORM_ADD_ARGS}

apply-tf: envs/$(STAGE)/.terraform	## shortcut to run terraform apply
	terraform apply ${TERRAFORM_ARGS}

init:
	terraform init -backend-config="./envs/$(STAGE)/terraform_backend_config_$(STAGE)$(CI_SUFFIX).tfvars" --upgrade

validate:
	terraform validate

plan:
	terraform plan ${TERRAFORM_ARGS}

help:
	@awk 'BEGIN {FS = ":.*##"; printf "Usage: make \033[36m<target>\033[0m\n"} /^[0-9a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-10s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

# some magic to get makefile parameters working
%:
	@:
