SHELL := bash# we want bash behaviour in all shell invocations

### PRIVATE VARS ###
#
export PATH 	:= $(CURDIR)/script:$(PATH)

WGET := wget --continue --show-progress

BOLD := $(shell tput bold)
NORMAL := $(shell tput sgr0)
CONFIRM := (press any key to confirm) 

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

.DEFAULT_GOAL = help

list_erlangs:
	@echo "Included Erlang versions: " ; \
	cd packages && \
	ls -1d erlang-* && echo

# Use multiple rules for the same target so that we first print, then set ERLANG_VERSION
erlang_version:: otp
ifndef ERLANG_TAG
	@cd otp && git pull --tags && echo -e "\nAdd the following Erlang package to this BOSH release:"
endif
erlang_version::
ifndef ERLANG_TAG
	$(eval ERLANG_TAG = $(shell cd otp ; select ERLANG_TAG in $$(git tag -l) ; do echo $$ERLANG_TAG ; break ; done))
endif
	$(eval ERLANG_VERSION = $(subst OTP-,,$(ERLANG_TAG)))
	$(eval ERLANG_TGZ = $(ERLANG_TAG).tar.gz)

tmp:
	@mkdir -p tmp

erlang_tgz: erlang_version tmp
	@$(WGET) --output-document=tmp/$(ERLANG_TGZ) \
	  https://github.com/erlang/otp/archive/$(ERLANG_TGZ)

add_erlang: list_erlangs erlang_tgz ## Add new Erlang package
	@bosh add-blob tmp/$(ERLANG_TGZ) erlang/$(ERLANG_TGZ) && \
	[ -d packages/erlang-$(ERLANG_VERSION) ] || \
	  cp -r $(shell ls -d packages/erlang-2* | tail -n 1) packages/erlang-$(ERLANG_VERSION) ; \
	gsed --in-place --regexp-extended --expression \
	  's/erlang-.+/erlang-$(ERLANG_VERSION)/g ; s/OTP-.*.tar.gz/$(ERLANG_TGZ)/g' \
	  packages/erlang-$(ERLANG_VERSION)/spec && echo && \
	git add -r packages/erlang-$(ERLANG_VERSION) && \
	read -rp "1/5 $(BOLD)erlang-$(ERLANG_VERSION)$(NORMAL) added to $(BOLD)packages:$(NORMAL) in $(BOLD)jobs/rabbitmq-server/spec$(NORMAL) $(CONFIRM)" -n 1 && \
	read -rp "2/5 $(BOLD)erlang.version$(NORMAL) property default maybe updated to $(BOLD)'$(ERLANG_VERSION)'$(NORMAL) in $(BOLD)jobs/rabbitmq-server/spec$(NORMAL) $(CONFIRM)" -n 1 && \
	gmake dev && \
	gmake deploy && \
	read -rp "3/5 $(BOLD)Erlang $(ERLANG_VERSION)$(NORMAL) confirmed via RabbitMQ Management UI $(CONFIRM)" -n 1 && \
	read -rp "4/5 Deployment deletes gracefully, e.g. $(BOLD)bosh -d DEPLOYMENT deld$(NORMAL) $(CONFIRM)" -n 1 && \
	bosh upload-blobs && \
	read -rp "5/5 All changes committed & pushed $(CONFIRM)" -n 1 && \
	echo -e "\nYou might want to run $(BOLD)gmake remove_erlang$(NORMAL)\n"

	# read -rp "3/8 $(BOLD)gmake dev$(NORMAL) succeeded $(CONFIRM)" -n 1 && \
	# read -rp "4/8 $(BOLD)gmake deploy$(NORMAL) with Erlang $(ERLANG_VERSION) succeeded $(CONFIRM)" -n 1 && \
	# read -rp "7/8 $(BOLD)bosh upload-blobs$(NORMAL) succeeded $(CONFIRM)" -n 1 && \

remove_erlang::
ifndef ERLANG_PACKAGE
	@echo -e "\nWhich Erlang package do you want to remove from this BOSH release?"
endif
remove_erlang::
ifndef ERLANG_PACKAGE
	$(eval ERLANG_PACKAGE = $(shell cd packages ; select ERLANG_PACKAGE in $$(ls -1d erlang-*) ; do echo $$ERLANG_PACKAGE ; break ; done))
endif
	$(eval ERLANG_VERSION = $(subst erlang-,,$(ERLANG_PACKAGE)))
remove_erlang:: ## Remove superseded Erlang package
	@bosh remove-blob erlang/OTP-$(ERLANG_VERSION).tar.gz && \
	git rm -r packages/$(ERLANG_PACKAGE) && echo && \
	read -rp "1/3 Remove package from $(BOLD)jobs/rabbitmq-server/spec$(NORMAL) $(CONFIRM)" -n 1 && \
	read -rp "2/3 Maybe update package dependency in $(BOLD)packages/looking_glass/spec$(NORMAL) $(CONFIRM)" -n 1 && \
	gmake dev && \
	read -rp "3/3 All changes committed & pushed $(CONFIRM)" -n 1

clean: 	## Clean all dev releases
	@rm -fr dev_releases

deps: 	## What are the required dependencies?
	@echo "$(DEPS_INFO)"

deploy: ## Deploy a RabbitMQ cluster
	@deploy

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-16s\033[0m %s\n", $$1, $$2}'

dev: 	update_submodules
dev: 	## Create a rabbitmq-server BOSH Dev release
	@create-dev-release

final: 	update_submodules
final: 	## Create a rabbitmq-server BOSH Final release - VERSION is required, e.g. VERSION=0.12.0
	@create-final-release $(VERSION)

update: ## Deploy an existing RabbitMQ cluster configuration - CONFIG is optional, it sets the deployment config, e.g. CONFIG=deployment_configurations/rmq-73734-3-7-2.yml
	@deploy-configuration $(CONFIG)

update_submodules:
	@git submodule update --init

otp:
	@git clone https://github.com/erlang/otp.git
