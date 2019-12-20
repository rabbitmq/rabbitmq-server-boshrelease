SHELL := bash# we want bash behaviour in all shell invocations
MAKEFILE := $(firstword $(MAKEFILE_LIST))
PLATFORM := $(shell uname)
platform = $(shell echo $(PLATFORM) | tr A-Z a-z)

### VARS ###
#
# https://stackoverflow.com/questions/4842424/list-of-ansi-color-escape-sequences
RED := \033[1;31m
GREEN := \033[1;32m
YELLOW := \033[1;33m
BOLD := \033[1m
NORMAL := \033[0m

LOCAL_BIN := $(CURDIR)/bin
GOPATH ?= $(HOME)/go
PATH := $(CURDIR)/script:$(LOCAL_BIN):$(GOPATH)/bin:$(PATH)
export PATH

CONFIRM := (press any key to confirm)

TODAY := $(shell date -u +'%Y.%m.%d')

ifeq ($(PLATFORM),Darwin)
OPEN := open
else
OPEN := xdg-open
endif

### TARGETS ###
#
.DEFAULT_GOAL = help

ifeq ($(PLATFORM),Darwin)
WGET := /usr/local/bin/wget
$(WGET):
	@brew install wget
else
WGET := /usr/bin/wget
$(WGET):
	$(error Please install wget)
endif
GET := $(WGET) --continue --show-progress

ifeq ($(PLATFORM),Darwin)
SED := /usr/local/bin/gsed
$(SED):
	@brew install gnu-sed
else
SED := /bin/sed
endif

ifeq ($(PLATFORM),Darwin)
LPASS := /usr/local/bin/lpass
$(LPASS):
	@brew install lastpass-cli
else
LPASS := /usr/bin/lpass
$(LPASS):
	$(error Please install lastpass-cli)
endif

ifeq ($(PLATFORM),Darwin)
GIT := /usr/local/bin/git
CHANGELOG := $(GIT)-changelog
$(GIT):
	@brew install git
$(CHANGELOG):
	@brew install git-extras
else
GIT := /usr/bin/git
$(GIT):
	$(error Please install git)
CHANGELOG := $(GIT)-changelog
$(CHANGELOG):
	$(error Please install git-extras)
endif

ifeq ($(PLATFORM),Darwin)
GO := /usr/local/opt/go/libexec/bin/go
$(GO): $(GIT)
	@brew install go || brew upgrade go
else
# Use the standard installation path for Linux:
# https://golang.org/doc/install#tarball
GO := /usr/local/go/bin/go
$(GO):
	$(error Please install golang)
endif

YAML2JSON := $(GOPATH)/bin/yaml2json
$(YAML2JSON): $(GO)
	@$(GO) get -u github.com/bronze1man/yaml2json

ifeq ($(PLATFORM),Darwin)
JQ := /usr/local/bin/jq
$(JQ):
	@brew install jq
else
JQ := /usr/bin/jq
$(JQ):
	$(error Please install jq)
endif

# https://github.com/cloudfoundry/bosh-cli/releases
BOSH_VERSION := 6.1.1
BOSH_BIN := bosh-cli-$(BOSH_VERSION)-$(platform)-amd64
BOSH_URL := https://s3.amazonaws.com/bosh-cli-artifacts/$(BOSH_BIN)
BOSH := $(LOCAL_BIN)/$(BOSH_BIN)
$(BOSH): $(WGET)
	@mkdir -p $(LOCAL_BIN) && cd $(LOCAL_BIN) && \
	$(GET) --output-document=$(BOSH) "$(BOSH_URL)" && \
	touch $(BOSH) && \
	chmod +x $(BOSH) && \
	$(BOSH) --version | grep $(BOSH_VERSION) && \
	ln -sf $(BOSH) $(LOCAL_BIN)/bosh
.PHONY: bosh
bosh: $(BOSH)
.PHONY: bosh_releases
bosh_releases:
	@$(OPEN) https://github.com/cloudfoundry/bosh-cli/releases

# https://github.com/k14s/ytt/releases
YTT_VERSION := 0.22.0
YTT_BIN := ytt-$(YTT_VERSION)-$(platform)-amd64
YTT_URL := https://github.com/k14s/ytt/releases/download/v$(YTT_VERSION)/ytt-$(platform)-amd64
YTT := $(LOCAL_BIN)/$(YTT_BIN)
.PHONY: $(YTT)
$(YTT): $(WGET)
	@mkdir -p $(LOCAL_BIN) && cd $(LOCAL_BIN) && \
	$(GET) --output-document=$(YTT) "$(YTT_URL)" && \
	touch $(YTT) && \
	chmod +x $(YTT) && \
	$(YTT) version | grep $(YTT_VERSION) && \
	ln -sf $(YTT) $(LOCAL_BIN)/ytt
.PHONY: ytt
ytt: $(YTT)
.PHONY: ytt_releases
ytt_releases:
	@$(OPEN) https://github.com/k14s/ytt/releases

WATCH := /usr/local/bin/watch
$(WATCH):
	@brew install watch
WATCH_MAKE_TARGET = $(WATCH) --color $(MAKE) --makefile $(MAKEFILE) --no-print-directory

define MAKE_TARGETS
  awk -F: '/^[^\.%\t][a-zA-Z\._\-]*:+.*$$/ { printf "%s\n", $$1 }' $(MAKEFILE_LIST)
endef
define BASH_AUTOCOMPLETE
  complete -W \"$$($(MAKE_TARGETS) | sort | uniq)\" make gmake m
endef
.PHONY: bash_autocomplete
bash_autocomplete: ## ba | Configure bash autocompletion - eval "$(make bash_autocomplete)"
	@printf "$(BASH_AUTOCOMPLETE)\n"
.PHONY: bac
bac: bash_autocomplete
# Continuous Feedback for the ac target - run in a split window while iterating on it
.PHONY: CFbac
CFbac: $(WATCH)
	@$(WATCH_MAKE_TARGET) bac

.PHONY: add_erlang
add_erlang: list_erlangs erlang_tgz $(BOSH) $(SED) $(GIT) ## Add new Erlang package
	@$(BOSH) add-blob tmp/$(ERLANG_TGZ) erlang/$(ERLANG_TGZ) && echo && \
	[ -d packages/erlang-$(ERLANG_VERSION) ] || \
	  cp -r $(shell ls -d packages/erlang-2* | tail -n 1) packages/erlang-$(ERLANG_VERSION) ; echo ; \
	$(SED) --in-place --regexp-extended --expression \
	  's/erlang-.+/erlang-$(ERLANG_VERSION)/g ; s/OTP-.*.tar.gz/$(ERLANG_TGZ)/g' \
	  packages/erlang-$(ERLANG_VERSION)/spec && echo && \
	$(GIT) add packages/erlang-$(ERLANG_VERSION) && echo && \
	printf "1/7 $(BOLD)erlang-$(ERLANG_VERSION)$(NORMAL) added to $(BOLD)packages:$(NORMAL) in $(BOLD)jobs/rabbitmq-server/spec$(NORMAL)" && \
	read -rp " $(CONFIRM)" -n 1 && \
	printf "2/7 Maybe update $(BOLD)erlang.version$(NORMAL) property default to $(BOLD)'$(ERLANG_VERSION)'$(NORMAL) in $(BOLD)jobs/rabbitmq-server/spec$(NORMAL)" && \
	read -rp " $(CONFIRM)" -n 1 && \
	printf "3/7 $(BOLD)make dev$(NORMAL) succeeded" && \
	read -rp " $(CONFIRM)" -n 1 && \
	printf "4/7 $(BOLD)make deploy$(NORMAL) with Erlang $(ERLANG_VERSION) succeeded" && \
	read -rp " $(CONFIRM)" -n 1 && \
	printf "5/7 Deployment deletes gracefully, e.g. $(BOLD)bosh -d DEPLOYMENT deld$(NORMAL)" && \
	read -rp " $(CONFIRM)" -n 1 && \
	printf "6/7 $(BOLD)bosh upload-blobs$(NORMAL) succeeded" && \
	read -rp " $(CONFIRM)" -n 1 && \
	printf "7/7 All changes committed & pushed" && \
	read -rp " $(CONFIRM)" -n 1 && \
	printf "\nYou might want to run $(BOLD)make remove_erlang$(NORMAL)\n\n"

OTP_VERSION = $(DEV_NAME)$(TODAY)
DEV_OTP_TGZ = OTP-$(OTP_VERSION).tar.gz
packages/erlang-$(OTP_VERSION): $(BOSH) $(SED) $(GIT) tmp ## Add a dev version of Erlang
	@read -rp "Add OTP source at path as Erlang dev package: " ERLANG_SOURCE_PATH && \
	cd $$ERLANG_SOURCE_PATH/.. && \
	tar zcvf $(CURDIR)/tmp/$(DEV_OTP_TGZ) --exclude '.git*' otp && \
	cd $(CURDIR) && \
	$(BOSH) add-blob tmp/$(DEV_OTP_TGZ) erlang/$(DEV_OTP_TGZ) && echo && \
	cp -r $(shell ls -d packages/erlang-2* | tail -n 1) packages/erlang-$(OTP_VERSION) ; echo ; \
	$(SED) --in-place --regexp-extended --expression \
	  's/erlang-.+/erlang-$(OTP_VERSION)/g ; s/OTP-.*.tar.gz/$(DEV_OTP_TGZ)/g' \
	  packages/erlang-$(OTP_VERSION)/spec && echo && \
	$(BOSH) interpolate \
	  --ops-file=operations/add-package.yml \
	  --var=package=erlang-$(OTP_VERSION) \
	  jobs/rabbitmq-server/spec > jobs/rabbitmq-server/spec2 && \
	  mv jobs/rabbitmq-server/spec{2,}
.PHONY: add_dev_erlang
add_dev_erlang: packages/erlang-$(OTP_VERSION)

.PHONY: add_dev_erlang
clean: 	## Clean all rabbitmq-server BOSH dev releases locally & from the BOSH Director
	@clean-dev-releases

.PHONY: deploy
deploy: $(BOSH) $(YAML2JSON) $(JQ) ## Deploy a RabbitMQ cluster
	@deploy

.PHONY: erlang_tgz
erlang_tgz: erlang_version tmp $(WGET)
	@$(GET) --output-document=tmp/$(ERLANG_TGZ) \
	  https://github.com/erlang/otp/archive/$(ERLANG_TGZ)

.PHONY: erlang_version
# Use multiple rules for the same target so that we first print, then set ERLANG_VERSION
erlang_version:: otp $(GIT)
ifndef ERLANG_TAG
	@cd otp && $(GIT) pull --tags && printf "\nAdd one of the following Erlang versions to this BOSH release:\n"
endif
define FILTER_OTP_TAGS
git tag -l | grep -e '^OTP-2[0-9].[0-9]*' | sort --version-sort
endef
erlang_version::
ifndef ERLANG_TAG
	$(eval ERLANG_TAG = $(shell cd otp ; select ERLANG_TAG in $$($(FILTER_OTP_TAGS)) ; do echo $$ERLANG_TAG ; break ; done))
endif
	$(eval ERLANG_VERSION = $(subst OTP-,,$(ERLANG_TAG)))
	$(eval ERLANG_TGZ = $(ERLANG_TAG).tar.gz)

.PHONY: help
help:
	@awk -F"[:#]" '/^[^\.][a-zA-Z\._\-]+:+.+##.+$$/ { printf "\033[36m%-24s\033[0m %s\n", $$1, $$4 }' $(MAKEFILE_LIST) \
	| sort
# Continuous Feedback for the help target - run in a split window while iterating on it
.PHONY: CFhelp
CFhelp: $(WATCH)
	@$(WATCH_MAKE_TARGET) help

.PHONY: dev
dev: 	$(LPASS) $(BOSH) ## Create a rabbitmq-server BOSH Dev release
	@create-dev-release

.PHONY: final
final::
ifndef VERSION
	@printf "$(RED)VERSION$(NORMAL) must be set to the final release version that will be created\n" && \
	printf "Final release versions that already exist:\n" && \
	_local_final_bosh_releases && \
	exit 1
endif
final:: $(LPASS) $(BOSH) ## Create a rabbitmq-server BOSH final release - VERSION is required, e.g. VERSION=n.n.n
	@create-final-release $(VERSION) && \
	shasum releases/rabbitmq-server/rabbitmq-server-$(VERSION).tgz > releases/rabbitmq-server/rabbitmq-server-$(VERSION).sha1

.PHONY: list_erlangs
list_erlangs:
	@printf "Erlang versions included in this BOSH release:\n" ; \
	cd packages && \
	ls -1d erlang-* && echo

otp: $(GIT)
	@$(GIT) clone https://github.com/erlang/otp.git

.PHONY: publish_final
publish_final::
ifndef VERSION
	@printf "$(RED)VERSION$(NORMAL) must be set to the final release version that will be published\n" && \
	printf "Local final release versions:\n" && \
	_local_final_bosh_releases && \
	exit 1
endif
publish_final:: $(GIT) $(CHANGELOG) ## Publish final rabbitmq-server BOSH release - VERSION is required, e.g. VERSION=n.n.n
	@read -rp "1/5 Update CHANGELOG.md with help from $(BOLD)git changelog$(NORMAL) $(CONFIRM)" -n 1 && \
	printf "2/5 Add final release tarball SHA1 to release notes in CHANGELOG.md:\n" && \
	printf '```\n' && \
	awk '{ print $$1 }' < releases/rabbitmq-server/rabbitmq-server-$(VERSION).sha1 && \
	printf '```\n' && \
	read -rp "$(CONFIRM)" -n 1 && \
	$(GIT) add --all && $(GIT) commit --gpg-sign --verbose --message "Cut v$(VERSION)" --edit && \
	$(GIT) tag --sign --message "https://github.com/rabbitmq/rabbitmq-server-boshrelease/releases/tag/v$(VERSION)" v$(VERSION) && $(GIT) push --tags && \
	$(OPEN) https://github.com/rabbitmq/rabbitmq-server-boshrelease/releases/new?tag=v$(VERSION) && \
	$(OPEN) releases/rabbitmq-server && \
	printf "3/5 Upload final release tarball & corresponding SHA1 file to GitHub release\n" && \
	read -rp "4/5 While you wait for the files to upload, use the latest CHANGELOG.md entry for title & release notes $(CONFIRM)" -n 1 && \
	read -rp "5/5 Publish final release on GitHub $(CONFIRM)" -n 1

.PHONY: ssh
ssh: $(BOSH) ## SSH into any VM managed by BOSH
	@_bosh_ssh_interactive

.PHONY: remove_erlang
remove_erlang::
ifndef ERLANG_PACKAGE
	@printf "\nWhich Erlang package do you want to remove from this BOSH release?\n"
endif
remove_erlang::
ifndef ERLANG_PACKAGE
	$(eval ERLANG_PACKAGE = $(shell cd packages ; select ERLANG_PACKAGE in $$(ls -1d erlang-*) ; do echo $$ERLANG_PACKAGE ; break ; done))
endif
	$(eval ERLANG_VERSION = $(subst erlang-,,$(ERLANG_PACKAGE)))
remove_erlang:: $(BOSH) $(GIT) $(SED) ## Remove superseded Erlang package
	@$(BOSH) remove-blob erlang/OTP-$(ERLANG_VERSION).tar.gz && echo && \
	$(GIT) rm -r packages/$(ERLANG_PACKAGE) && echo && \
	$(SED) --in-place --regexp-extended --expression '/^- erlang-$(ERLANG_VERSION)$$/d' jobs/rabbitmq-server/spec && \
	printf "1/2 $(BOLD)make dev$(NORMAL) succeeded" && \
	read -rp " $(CONFIRM)" -n 1 && \
	printf "2/2 All changes committed & pushed" && \
	read -rp " $(CONFIRM)" -n 1

tmp:
	@mkdir -p tmp

.PHONY: update
update: ## Deploy an existing RabbitMQ cluster configuration - CONFIG is optional, e.g. CONFIG=deployment_configurations/rmq-n.yml
	@deploy-configuration $(CONFIG)

.PHONY: test_scripts
test_scripts: ## Run in the same environment as the BOSH Stemcell - Ubuntu Trust, 16.04
	@docker run --interactive --tty --rm \
	  --volume $(CURDIR):/workspace --workdir /workspace \
	  ubuntu:16.04 \
	  bash
