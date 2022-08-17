CHANNEL=$(shell basename $(shell pwd))

SRC_IMAGE := springio/petclinic:latest

REGISTRY := registry.replicated.com
PROJECT  := ${REPLICATED_APP}

BUNDLE_DIR := ./bundle
REPO_DIR := ./repository
KOTS_DIR   := ./manifests

BUNDLE_MANIFESTS := $(shell find $(BUNDLE_DIR) -name '*.yaml')
KOTS_MANIFESTS := $(shell find $(KOTS_DIR) -name '*.yaml')
REPO_MANIFESTS := $(shell find $(REPO_DIR) -name '*.yaml' -o -name '*.yml')

lint: $(KOTS_MANIFESTS)
	@replicated release lint --yaml-dir $(KOTS_DIR)

lock: $(BUNDLE_MANIFESTS)
	@kbld --file $(BUNDLE_DIR) --imgpkg-lock-output $(BUNDLE_DIR)/.imgpkg/images.yml >/dev/null

image: lock
	@imgpkg copy --image $(SRC_IMAGE) --to-repo $(REGISTRY)/$(PROJECT)/petclinic

bundle: image
	@imgpkg push --bundle $(REGISTRY)/$(PROJECT)/bundle --file $(BUNDLE_DIR)

repository: $(REPO_MANIFESTS)
	@imgpkg push --bundle $(REGISTRY)/$(PROJECT)/repository --file $(REPO_DIR)

release: $(KOTS_MANIFESTS)
	@replicated release create \
		--app ${REPLICATED_APP} \
		--token ${REPLICATED_API_TOKEN} \
		--auto -y \
		--yaml-dir $(KOTS_DIR) \
		--promote $(CHANNEL)

clean:
	rm $(MANIFESTS)
