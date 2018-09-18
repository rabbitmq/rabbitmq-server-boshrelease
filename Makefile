SHELL := bash# we want bash behaviour in all shell invocations

### PRIVATE VARS ###
#
#
LOCAL_BIN := $(CURDIR)/bin
PATH := $(CURDIR)/script:$(LOCAL_BIN):$(PATH)
export PATH

RED := $(shell tput setaf 1)
GREEN := $(shell tput setaf 2)
YELLOW := $(shell tput setaf 3)
BOLD := $(shell tput bold)
NORMAL := $(shell tput sgr0)
CONFIRM := (press any key to confirm) 

WGET := /usr/local/bin/wget
GET := wget --continue --show-progress
SED := /usr/local/bin/gsed

LPASS := /usr/local/bin/lpass

GIT := /usr/local/bin/git
GO := /usr/local/opt/go/libexec/bin/go
YAML2JSON := $(GOPATH)/bin/yaml2json

JQ := /usr/local/bin/jq

BOSH_VERSION := 5.2.2
BOSH_BIN := bosh-cli-$(BOSH_VERSION)-darwin-amd64
BOSH_URL := https://s3.amazonaws.com/bosh-cli-artifacts/$(BOSH_BIN)
BOSH := $(LOCAL_BIN)/$(BOSH_BIN)

### TARGETS ###
#

.DEFAULT_GOAL = help

$(WGET):
	@brew install wget

$(SED):
	@brew install gnu-sed

$(LPASS):
	@brew install lastpass-cli

$(GIT):
	@brew install git

$(GO): $(GIT)
	@brew install go || brew upgrade go

$(YAML2JSON): $(GO)
	@go get -u github.com/bronze1man/yaml2json

$(JQ):
	@brew install jq

$(BOSH): $(WGET)
	@mkdir -p $(LOCAL_BIN) && cd $(LOCAL_BIN) && \
	$(GET) --output-document=$(BOSH) "$(BOSH_URL)" && \
	touch $(BOSH) && \
	chmod +x $(BOSH) && \
	$(BOSH) --version | grep $(BOSH_VERSION) && \
	ln -sf $(BOSH) $(LOCAL_BIN)/bosh
bosh_releases:
	@$(OPEN) https://github.com/cloudfoundry/bosh-cli/releases

add_erlang: list_erlangs erlang_tgz $(BOSH) $(SED) $(GIT) ## Add new Erlang package
	@$(BOSH) add-blob tmp/$(ERLANG_TGZ) erlang/$(ERLANG_TGZ) && echo && \
	[ -d packages/erlang-$(ERLANG_VERSION) ] || \
	  cp -r $(shell ls -d packages/erlang-2* | tail -n 1) packages/erlang-$(ERLANG_VERSION) ; echo ; \
	$(SED) --in-place --regexp-extended --expression \
	  's/erlang-.+/erlang-$(ERLANG_VERSION)/g ; s/OTP-.*.tar.gz/$(ERLANG_TGZ)/g' \
	  packages/erlang-$(ERLANG_VERSION)/spec && echo && \
	$(GIT) add packages/erlang-$(ERLANG_VERSION) && echo && \
	read -rp "1/7 $(BOLD)erlang-$(ERLANG_VERSION)$(NORMAL) added to $(BOLD)packages:$(NORMAL) in $(BOLD)jobs/rabbitmq-server/spec$(NORMAL) $(CONFIRM)" -n 1 && \
	read -rp "2/7 Maybe update $(BOLD)erlang.version$(NORMAL) property default to $(BOLD)'$(ERLANG_VERSION)'$(NORMAL) in $(BOLD)jobs/rabbitmq-server/spec$(NORMAL) $(CONFIRM)" -n 1 && \
	read -rp "3/7 $(BOLD)gmake dev$(NORMAL) succeeded $(CONFIRM)" -n 1 && \
	read -rp "4/7 $(BOLD)gmake deploy$(NORMAL) with Erlang $(ERLANG_VERSION) succeeded $(CONFIRM)" -n 1 && \
	read -rp "5/7 Deployment deletes gracefully, e.g. $(BOLD)bosh -d DEPLOYMENT deld$(NORMAL) $(CONFIRM)" -n 1 && \
	read -rp "6/7 $(BOLD)bosh upload-blobs$(NORMAL) succeeded $(CONFIRM)" -n 1 && \
	read -rp "7/7 All changes committed & pushed $(CONFIRM)" -n 1 && \
	echo -e "\nYou might want to run $(BOLD)gmake remove_erlang$(NORMAL)\n"

clean: 	## Clean all dev releases
	@rm -fr dev_releases

deploy: $(BOSH) $(YAML2JSON) $(JQ) ## Deploy a RabbitMQ cluster
	@deploy

erlang_tgz: erlang_version tmp $(WGET)
	@$(GET) --output-document=tmp/$(ERLANG_TGZ) \
	  https://github.com/erlang/otp/archive/$(ERLANG_TGZ)

# Use multiple rules for the same target so that we first print, then set ERLANG_VERSION
erlang_version:: otp $(GIT)
ifndef ERLANG_TAG
	@cd otp && $(GIT) pull --tags && echo -e "\nAdd the following Erlang package to this BOSH release:"
endif
erlang_version::
ifndef ERLANG_TAG
	$(eval ERLANG_TAG = $(shell cd otp ; select ERLANG_TAG in $$(git tag -l) ; do echo $$ERLANG_TAG ; break ; done))
endif
	$(eval ERLANG_VERSION = $(subst OTP-,,$(ERLANG_TAG)))
	$(eval ERLANG_TGZ = $(ERLANG_TAG).tar.gz)

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-16s\033[0m %s\n", $$1, $$2}'

dev: 	submodules $(LPASS) $(BOSH) ## Create a rabbitmq-server BOSH Dev release
	@create-dev-release

final::
ifndef VERSION
	@echo "$(RED)VERSION$(NORMAL) must be set to the final release version that will be created" && \
	echo "Final release versions that already exist:" && \
	_rmq_bosh_releases && \
	exit 1
endif
final:: submodules $(LPASS) $(BOSH) ## Create a rabbitmq-server BOSH final release - VERSION is required, e.g. VERSION=0.15.0
	@create-final-release $(VERSION) && \
	shasum releases/rabbitmq-server/rabbitmq-server-$(VERSION).tgz > releases/rabbitmq-server/rabbitmq-server-$(VERSION).sha1 && \

list_erlangs:
	@echo "Included Erlang versions: " ; \
	cd packages && \
	ls -1d erlang-* && echo

otp: $(GIT)
	@$(GIT) clone https://github.com/erlang/otp.git

publish_final::
ifndef VERSION
	@echo "$(RED)VERSION$(NORMAL) must be set to the final release version that will be published" && \
	echo "Local final release versions:" && \
	_local_final_bosh_releases && \
	exit 1
endif
publish_final:: $(GIT) ## Publish final rabbitmq-server BOSH release - VERSION is required, e.g. VERSION=0.15.0
	@read -rp "1/5 Update CHANGELOG.md with help from $(BOLD)git changelog$(NORMAL) $(CONFIRM)" -n 1 && \
	echo "2/5 Add final release tarball SHA1 to release notes in CHANGELOG.md:" && \
	echo '```' && \
	awk '{ print $$1 }' < releases/rabbitmq-server/rabbitmq-server-$(VERSION).sha1 && \
	echo '```' && \
	read -rp "$(CONFIRM)" -n 1 && \
	$(GIT) add --all && $(GIT) commit --gpg-sign --verbose --message "Cut v$(VERSION)" --edit && \
	$(GIT) tag --sign --message "https://github.com/rabbitmq/rabbitmq-server-boshrelease/releases/tag/v$(VERSION)" v$(VERSION) && $(GIT) push --tags && \
	open https://github.com/rabbitmq/rabbitmq-server-boshrelease/releases/new?tag=v$(VERSION) && \
	open releases/rabbitmq-server && \
	echo "3/5 Upload final release tarball & corresponding SHA1 file to GitHub release" && \
	read -rp "4/5 While you wait for the files to upload, use the latest CHANGELOG.md entry for title & release notes $(CONFIRM)" -n 1 && \
	read -rp "5/5 Publish final release on GitHub $(CONFIRM)" -n 1

ssh: $(BOSH) ## SSH into any VM managed by BOSH
	@_bosh_ssh_interactive

remove_erlang::
ifndef ERLANG_PACKAGE
	@echo -e "\nWhich Erlang package do you want to remove from this BOSH release?"
endif
remove_erlang::
ifndef ERLANG_PACKAGE
	$(eval ERLANG_PACKAGE = $(shell cd packages ; select ERLANG_PACKAGE in $$(ls -1d erlang-*) ; do echo $$ERLANG_PACKAGE ; break ; done))
endif
	$(eval ERLANG_VERSION = $(subst erlang-,,$(ERLANG_PACKAGE)))
remove_erlang:: $(BOSH) $(GIT) ## Remove superseded Erlang package
	@$(BOSH) remove-blob erlang/OTP-$(ERLANG_VERSION).tar.gz && echo && \
	$(GIT) rm -r packages/$(ERLANG_PACKAGE) && echo && \
	read -rp "1/5 Remove package from $(BOLD)jobs/rabbitmq-server/spec$(NORMAL) $(CONFIRM)" -n 1 && \
	read -rp "2/5 Maybe update package dependency in $(BOLD)packages/looking_glass/spec$(NORMAL) $(CONFIRM)" -n 1 && \
	read -rp "3/5 Maybe update package dependency in $(BOLD)packages/prometheus.erl/spec$(NORMAL) $(CONFIRM)" -n 1 && \
	read -rp "4/5 $(BOLD)gmake dev$(NORMAL) succeeded $(CONFIRM)" -n 1 && \
	read -rp "5/5 All changes committed & pushed $(CONFIRM)" -n 1

tmp:
	@mkdir -p tmp

update: ## Deploy an existing RabbitMQ cluster configuration - CONFIG is optional, it sets the deployment config, e.g. CONFIG=deployment_configurations/rmq-73734-3-7-2.yml
	@deploy-configuration $(CONFIG)

submodules: $(GIT)
	@$(GIT) submodule update --init
