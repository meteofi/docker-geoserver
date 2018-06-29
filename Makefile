GEOSERVER_MAJOR ?= 2.13
GEOSERVER_MINOR ?= 1
GEOSERVER_VERSION ?= "$(GEOSERVER_MAJOR).$(GEOSERVER_MINOR)"
TAG ?= $(GEOSERVER_VERSION)

default: build

build:
	docker build --rm --tag "meteofi/geoservertest:$(GEOSERVER_VERSION)" \
	                  --tag "meteofi/geoservertest:$(GEOSERVER_MAJOR)" \
                          --build-arg GEOSERVER_VERSION=$(GEOSERVER_VERSION) .
