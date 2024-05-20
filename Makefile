default: help

ENVIRONMENT ?= qa

CLUSTER_MGMT=docker run --rm -it \
-e VAULT_ADDR -e VAULT_TOKEN -e GITHUB_TOKEN -e ENVIRONMENT -e DEBUG -e USE_REPO_AS_STATE_KEY=true \
-v ~/.aws/credentials:/root/.aws/credentials -v `pwd`:/repo \
-w /repo \
docker.elastic.co/cloud/cluster-mgmt-agent:latest

plan: ## Runs a plan against all local resources
	$(CLUSTER_MGMT) plan


apply: ## Runs a apply against all local resources - usually done by CI
	@echo "Are you sure you want to apply local resources to the '$(ENVIRONMENT)' environment? Have you looked at the plan first? [y/N]" && read ans && [ $${ans:-N} = y ]
	$(CLUSTER_MGMT) apply


help: ## Display this help screen
	@echo "Usage: make <target>"
	@echo ""
	@echo "Targets:"
	@echo ""
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)	


# # Define variables
# ENVIRONMENT ?= qa
# AWS_PROFILE ?= ecqa
# O11Y_DIR ?= ".o11y"
# EXTRA_ARGS=""
# MODULE_SRC_PREFIX ?= "modules"
# BASECONFIG_BUCKET="cluster-mgmt-${ENVIRONMENT}"
# ENV_BASECONF_DIR ?= "baseconfig/${ENVIRONMENT}.conf.d"
# BASECONF_DIR ?= "baseconfig/base.conf.d"

# # AWS credentials
# AWS_ACCESS_KEY_ID = $(shell aws --profile ${AWS_PROFILE} configure export-credentials | jq -r .AccessKeyId)
# AWS_SECRET_ACCESS_KEY = $(shell aws --profile ${AWS_PROFILE} configure export-credentials | jq -r .SecretAccessKey)
# AWS_SESSION_TOKEN = $(shell aws --profile ${AWS_PROFILE} configure export-credentials | jq -r .SessionToken)

# .PHONY: push apply sync

# # Sync target
# sync:
# 	# Add your sync command here
# 	aws --profile ${AWS_PROFILE} s3 sync --delete s3://${BASECONFIG_BUCKET}/${BASECONF_DIR} ${O11Y_DIR}/${BASECONF_DIR}
# 	aws --profile ${AWS_PROFILE} s3 sync --delete s3://${BASECONFIG_BUCKET}/${ENV_BASECONF_DIR} ${O11Y_DIR}/${ENV_BASECONF_DIR}
	
# # Run target
# plan: sync
# 	@echo "Running docker.elastic.co/cloud/cluster-mgmt plan --target-env ${ENVIRONMENT}"
# 	@docker run \
# 		-v $(PWD):/root/ \
# 		--env "AWS_ACCESS_KEY_ID=$(AWS_ACCESS_KEY_ID)" \
# 		--env "AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}" \
# 		--env "AWS_SESSION_TOKEN=${AWS_SESSION_TOKEN}" \
# 		--env "VAULT_TOKEN=${VAULT_TOKEN}" \
# 		--env "VAULT_ADDR=${VAULT_ADDR}" \
# 		docker.elastic.co/cloud/cluster-mgmt plan --config-dir=/root/.o11y/conf.d --config-dir=/root/.o11y/baseconfig/base.conf.d --config-dir=/root/.o11y/baseconfig/${ENVIRONMENT}.conf.d --target-env ${ENVIRONMENT} --resource-dir=/root/.o11y/ --module-source-prefix-override=${MODULE_SRC_PREFIX} -o /root/.o11y/out

# # apply target
# apply: sync
# 	@docker run \
# 		-v $(PWD):/root/ \
# 		--env "AWS_ACCESS_KEY_ID=$(AWS_ACCESS_KEY_ID)" \
# 		--env "AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}" \
# 		--env "AWS_SESSION_TOKEN=${AWS_SESSION_TOKEN}" \
# 		--env "VAULT_TOKEN=${VAULT_TOKEN}" \
# 		--env "VAULT_ADDR=${VAULT_ADDR}" \
# 		docker.elastic.co/cloud/cluster-mgmt apply --config-dir=/root/.o11y/conf.d --config-dir=/root/.o11y/baseconfig/base.conf.d --config-dir=/root/.o11y/baseconfig/${ENVIRONMENT}.conf.d --target-env ${ENVIRONMENT} --resource-dir=/root/.o11y/ --module-source-prefix-override=${MODULE_SRC_PREFIX} -o /root/.o11y/out


# # Destroy target
# clean:
# 	@rm -rf ./.o11y/out
# 	@rm -rf ./.o11y/baseconfig


	