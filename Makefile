CHANNEL=$(shell basename $(shell pwd))

REGISTRY := registry.shortrib.dev
PROJECT  := library

BUNDLE_DIR := ./bundle
KOTS_DIR   := ./manifests


BUNDLE_MANIFESTS := $(shell find $(BUNDLE_DIR) -name '*.yaml')
KOTS_MANIFESTS := $(shell find $(KOTS_DIR) -name '*.yaml')

lint: $(KOTS_MANIFESTS)
	@replicated release lint --yaml-dir $(KOTS_DIR)

lock: $(BUNDLE_MANIFESTS)
	@kbld -f $(BUNDLE_DIR) --imgpkg-lock-output $(BUNDLE_DIR)/.imgpkg/images.yml >/dev/null

bundle: lock
	@imgpkg push -b $(REGISTRY)/$(PROJECT)/$(CHANNEL) -f $(BUNDLE_DIR)

release: $(KOTS_MANIFESTS)
	@replicated release create \
		--app ${REPLICATED_APP} \
		--token ${REPLICATED_API_TOKEN} \
		--auto -y \
		--yaml-dir $(KOTS_DIR) \
		--promote $(CHANNEL)

clean:
	rm $(MANIFESTS)
