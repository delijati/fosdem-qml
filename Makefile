# clickable-ut is installed and run by uv (uvx keeps it in the uv tool cache,
# nothing in the repo, so no venv with absolute paths that break when the
# repo moves). Clickable builds inside docker or podman containers.

CLICKABLE := uvx --python 3.12 --from 'clickable-ut>=8.4.0' clickable

# With podman, clickable runs its containers with "--uidmap" for the IDs
# 0-1000 only, and "podman run --uidmap" pulls a missing image with that
# mapping. The 24.04 images contain files owned by UID 32011, so that pull
# fails with "container ID 32011 cannot be mapped to a host ID". A plain
# "podman pull" first avoids it. The container tool is chosen as clickable
# does: podman unless CLICKABLE_DOCKER_COMMAND is set.
CONTAINER_CMD = $(or $(CLICKABLE_DOCKER_COMMAND),$(if $(shell command -v podman),podman,docker))
HOST_ARCH = $(if $(filter aarch64 arm64,$(shell uname -m)),arm64,amd64)
IMAGE = docker.io/clickable/$(HOST_ARCH)-ut24.04-1.x-$(HOST_ARCH)
# Clickable turns on nvidia mode when the nvidia driver is loaded. With podman
# that mode needs nvidia-docker version 1 (clickable takes podman's version for
# a docker older than 19.03), with docker the NVIDIA Container Toolkit. The app
# does not need the GPU, so desktop runs without it unless CLICKABLE_NVIDIA=1.
NVIDIA = $(if $(CLICKABLE_NO_NVIDIA),,$(CLICKABLE_NVIDIA))
DESKTOP_IMAGE = $(IMAGE)$(if $(NVIDIA),-nvidia)
DESKTOP_FLAGS = $(if $(NVIDIA),--nvidia,--no-nvidia)
pull = if [ "$(CONTAINER_CMD)" = podman ] && ! podman image exists $(1); then \
	echo "podman pull $(1) (before clickable, see Makefile)"; podman pull $(1); fi

.PHONY: help install build desktop device logs review test smoke screenshots bump clean

help:
	@echo "make install    install clickable-ut with uv (also done by the first clickable target)"
	@echo "make build      build the click package (build/all/app/*.click)"
	@echo "make desktop    run the app on this computer"
	@echo "make device     build, install and start the app on a phone via USB"
	@echo "make logs       follow the app log on the phone"
	@echo "make review     run the OpenStore review on the built click"
	@echo "make test       python backend tests (pytest, Python 3.12)"
	@echo "make smoke      QML smoke check in the 24.04 SDK image"
	@echo "make screenshots  README screenshots into docs/screenshots (demo schedule)"
	@echo "make bump PART=patch|minor|major  new version: commit + tag (clean tree needed)"
	@echo "make clean      remove build/"

install:
	$(CLICKABLE) --version

build:
	@$(call pull,$(IMAGE))
	$(CLICKABLE) build

desktop:
	@$(call pull,$(DESKTOP_IMAGE))
	$(CLICKABLE) desktop $(DESKTOP_FLAGS)

device:
	@$(call pull,$(IMAGE))
	$(CLICKABLE)

logs:
	$(CLICKABLE) logs

review:
	@$(call pull,$(IMAGE))
	$(CLICKABLE) review

test:
	PYTHONDONTWRITEBYTECODE=1 uv run --no-project --python 3.12 --with pytest \
		pytest -q -p no:cacheprovider -W error tests

smoke:
	tools/qml-smoke.sh

screenshots:
	tools/screenshots.sh

# bump2version (.bumpversion.cfg) changes the version in the backend and the
# manifest, commits and tags; "git push --follow-tags" publishes it.
PART ?= patch
bump:
	uvx bump2version --verbose $(PART)

clean:
	rm -rf build
