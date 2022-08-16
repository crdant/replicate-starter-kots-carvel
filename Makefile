CHANNEL=$(shell basename $(shell pwd))

BUILD_DIR  := ./build
SOURCE_DIR := ./manifests

SRCS      := $(shell find $(SOURCE_DIR) -name '*.yaml' -execdir basename '{}' ';')
MANIFESTS := $(SRCS:%=$(BUILD_DIR)/%)

$(BUILD_DIR)/%.yaml: $(SOURCE_DIR)/%.yaml
	ytt -f ytt -f $< > $@

$(BUILD_DIR): $(MANIFESTS)

lint: build
	@replicated release lint --yaml-dir $(BUILD_DIR)
	
release: build
	@replicated release create \
		--app ${REPLICATED_APP} \
		--token ${REPLICATED_API_TOKEN} \
		--auto -y \
		--yaml-dir build \
		--promote $(CHANNEL)

clean:
	rm $(MANIFESTS)
