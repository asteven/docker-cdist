REGISTRY = docker.io
IMG_NAMESPACE = asteven
IMG_NAME = cdist
IMG_FQNAME = $(REGISTRY)/$(IMG_NAMESPACE)/$(IMG_NAME)
IMG_VERSION = 0.1.3
# Prefere podman over docker for building.
BUILDER = $(shell which podman || which docker)


.PHONY: populate-cache build-cache build-runtime push clean
all: build-runtime

# Decided no longer push the compile images to docker hub.
# They are therefore local to the build host.
#populate-cache:
#	# Pull the latest version of the image, in order to
#	# populate the build cache:
#	sudo $(BUILDER) pull $(IMG_FQNAME):compile-stage || true
#	sudo $(BUILDER) pull $(IMG_FQNAME):latest || true

#build-cache: populate-cache
build-cache:
	# Build the compile stage:
	sudo $(BUILDER) build --pull --target compile-image \
		--cache-from=$(IMG_FQNAME):compile-stage \
		--tag $(IMG_FQNAME):compile-stage .

build-runtime: build-cache
	# Build the runtime stage, using cached compile stage:
	sudo $(BUILDER) build --pull --target runtime-image \
		--cache-from=$(IMG_FQNAME):compile-stage \
		--cache-from=$(IMG_FQNAME):latest \
		--tag $(IMG_FQNAME):$(IMG_VERSION) \
		--tag $(IMG_FQNAME):latest .

push:
	#sudo $(BUILDER) push $(IMG_FQNAME):compile-stage docker://$(IMG_FQNAME):compile-stage
	sudo $(BUILDER) push $(IMG_FQNAME):$(IMG_VERSION) docker://$(IMG_FQNAME):$(IMG_VERSION)
	# Also update :latest
	sudo $(BUILDER) push $(IMG_FQNAME):latest docker://$(IMG_FQNAME):latest

clean:
	sudo $(BUILDER) rmi $(IMG_FQNAME):$(IMG_VERSION) || true
	sudo $(BUILDER) rmi $(IMG_FQNAME):latest || true

mrproper: clean
	sudo $(BUILDER) rmi $(IMG_FQNAME):compile-stage

