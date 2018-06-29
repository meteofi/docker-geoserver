GEOSERVER_VERSION ?= 2.13.1
TAG ?= $(GEOSERVER_VERSION)

default: build

build:
	docker build --rm -t geoserver --build-arg GEOSERVER_VERSION=$(GEOSERVER_VERSION) .
