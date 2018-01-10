.ONESHELL:# single shell invocation for all lines in the recipe

.DEFAULT_GOAL = help

### VARIABLES ###
#
export PATH 	:= $(CURDIR)/script:$(PATH)

define DEPS_INFO
 _______________________________________________________
|
|  Ensure that you are targeting the correct BOSH director
|  If you need help setting up a BOSH, see https://github.com/cloudfoundry/bosh-bootloader
|
|  Ensure the following are installed and available in PATH :
|
|    * bosh cli v2 - https://bosh.io/docs/cli-v2.html
|    * jq - https://github.com/stedolan/jq
|    * yq - https://github.com/abesto/yq
|    * lpass cli - https://github.com/lastpass/lastpass-cli
|
|  You're now ready to BOSH some RabbitMQ clusters
|
endef

### TARGETS ###
#

deps: ## What are the required dependencies?
	@echo "$(DEPS_INFO)"

deploy: ## Deploy a new RabbitMQ cluster
	@deploy

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

dev: _update_submodules ## Create a new BOSH DEV release of rabbitmq-server
	@create-dev-release

final: _update_submodules ## Create a new BOSH FINAL release of rabbitmq-server
	@create-final-release

update: ## Deploy an existing RabbitMQ cluster configuration, optionally set the deployment config path, e.g. C=deployment_configurations/rmq-73734-3-7-2.yml
	@deploy-configuration $(C)

_update_submodules:
	@git submodule update --init
