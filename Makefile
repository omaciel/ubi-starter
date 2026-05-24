.PHONY: help build-all run-all clean-all
.PHONY: build-rhel8 build-rhel9 build-rhel10
.PHONY: run-rhel8 run-rhel9 run-rhel10
.PHONY: clean-rhel8 clean-rhel9 clean-rhel10

# Container runtime detection (docker or podman)
CONTAINER_RUNTIME := $(shell command -v docker 2>/dev/null || command -v podman 2>/dev/null)
ifeq ($(CONTAINER_RUNTIME),)
$(error Neither docker nor podman found in PATH. Please install one of them.)
endif

# User configuration
USERNAME := flash
USER_UID := $(shell id -u)
USER_GID := $(shell id -g)

# Optional tool installation flags (set to 'true' to enable)
INSTALL_DEV_TOOLS ?= false
INSTALL_BUILD_TOOLS ?= false
INSTALL_NET_TOOLS ?= false

# Volume mount configuration
LOCAL_DIR := $(CURDIR)
CONTAINER_DIR := /home/$(USERNAME)/data

# RHEL version configurations
RHEL8_IMAGE := localhost/ubi8/ubi:latest
RHEL9_IMAGE := localhost/ubi9/ubi:latest
RHEL10_IMAGE := localhost/ubi10/ubi:latest

help:
	@echo "Available targets:"
	@echo ""
	@echo "Build targets:"
	@echo "  build-rhel8   - Build RHEL 8 container"
	@echo "  build-rhel9   - Build RHEL 9 container"
	@echo "  build-rhel10  - Build RHEL 10 container"
	@echo "  build-all     - Build all RHEL containers"
	@echo ""
	@echo "Run targets:"
	@echo "  run-rhel8     - Run RHEL 8 container with current directory mounted"
	@echo "  run-rhel9     - Run RHEL 9 container with current directory mounted"
	@echo "  run-rhel10    - Run RHEL 10 container with current directory mounted"
	@echo ""
	@echo "Clean targets:"
	@echo "  clean-rhel8   - Remove RHEL 8 container image"
	@echo "  clean-rhel9   - Remove RHEL 9 container image"
	@echo "  clean-rhel10  - Remove RHEL 10 container image"
	@echo "  clean-all     - Remove all RHEL container images"

# RHEL 8 targets
build-rhel8:
	@echo "Building RHEL 8 container image..."
	@echo "Using UID=$(USER_UID) and GID=$(USER_GID)"
	@echo "Optional tools: DEV=$(INSTALL_DEV_TOOLS), BUILD=$(INSTALL_BUILD_TOOLS), NET=$(INSTALL_NET_TOOLS)"
	$(CONTAINER_RUNTIME) build -f Containerfile.rhel8 \
		--build-arg USERNAME=$(USERNAME) \
		--build-arg USER_UID=$(USER_UID) \
		--build-arg USER_GID=$(USER_GID) \
		--build-arg INSTALL_DEV_TOOLS=$(INSTALL_DEV_TOOLS) \
		--build-arg INSTALL_BUILD_TOOLS=$(INSTALL_BUILD_TOOLS) \
		--build-arg INSTALL_NET_TOOLS=$(INSTALL_NET_TOOLS) \
		-t $(RHEL8_IMAGE) \
		.

run-rhel8:
	@echo "Running RHEL 8 container with volume mount:"
	@echo "  Local:     $(LOCAL_DIR)"
	@echo "  Container: $(CONTAINER_DIR)"
	$(CONTAINER_RUNTIME) run -it --rm \
		-v $(LOCAL_DIR):$(CONTAINER_DIR) \
		$(RHEL8_IMAGE)

clean-rhel8:
	@echo "Removing RHEL 8 container image $(RHEL8_IMAGE)"
	$(CONTAINER_RUNTIME) rmi $(RHEL8_IMAGE)

# RHEL 9 targets
build-rhel9:
	@echo "Building RHEL 9 container image..."
	@echo "Using UID=$(USER_UID) and GID=$(USER_GID)"
	@echo "Optional tools: DEV=$(INSTALL_DEV_TOOLS), BUILD=$(INSTALL_BUILD_TOOLS), NET=$(INSTALL_NET_TOOLS)"
	$(CONTAINER_RUNTIME) build -f Containerfile.rhel9 \
		--build-arg USERNAME=$(USERNAME) \
		--build-arg USER_UID=$(USER_UID) \
		--build-arg USER_GID=$(USER_GID) \
		--build-arg INSTALL_DEV_TOOLS=$(INSTALL_DEV_TOOLS) \
		--build-arg INSTALL_BUILD_TOOLS=$(INSTALL_BUILD_TOOLS) \
		--build-arg INSTALL_NET_TOOLS=$(INSTALL_NET_TOOLS) \
		-t $(RHEL9_IMAGE) \
		.

run-rhel9:
	@echo "Running RHEL 9 container with volume mount:"
	@echo "  Local:     $(LOCAL_DIR)"
	@echo "  Container: $(CONTAINER_DIR)"
	$(CONTAINER_RUNTIME) run -it --rm \
		-v $(LOCAL_DIR):$(CONTAINER_DIR) \
		$(RHEL9_IMAGE)

clean-rhel9:
	@echo "Removing RHEL 9 container image $(RHEL9_IMAGE)"
	$(CONTAINER_RUNTIME) rmi $(RHEL9_IMAGE)

# RHEL 10 targets
build-rhel10:
	@echo "Building RHEL 10 container image..."
	@echo "Using UID=$(USER_UID) and GID=$(USER_GID)"
	@echo "Optional tools: DEV=$(INSTALL_DEV_TOOLS), BUILD=$(INSTALL_BUILD_TOOLS), NET=$(INSTALL_NET_TOOLS)"
	$(CONTAINER_RUNTIME) build -f Containerfile.rhel10 \
		--build-arg USERNAME=$(USERNAME) \
		--build-arg USER_UID=$(USER_UID) \
		--build-arg USER_GID=$(USER_GID) \
		--build-arg INSTALL_DEV_TOOLS=$(INSTALL_DEV_TOOLS) \
		--build-arg INSTALL_BUILD_TOOLS=$(INSTALL_BUILD_TOOLS) \
		--build-arg INSTALL_NET_TOOLS=$(INSTALL_NET_TOOLS) \
		-t $(RHEL10_IMAGE) \
		.

run-rhel10:
	@echo "Running RHEL 10 container with volume mount:"
	@echo "  Local:     $(LOCAL_DIR)"
	@echo "  Container: $(CONTAINER_DIR)"
	$(CONTAINER_RUNTIME) run -it --rm \
		-v $(LOCAL_DIR):$(CONTAINER_DIR) \
		$(RHEL10_IMAGE)

clean-rhel10:
	@echo "Removing RHEL 10 container image $(RHEL10_IMAGE)"
	$(CONTAINER_RUNTIME) rmi $(RHEL10_IMAGE)

# Convenience targets for all versions
build-all: build-rhel8 build-rhel9 build-rhel10

clean-all: clean-rhel8 clean-rhel9 clean-rhel10
