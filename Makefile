IMAGE ?= meteofi/geoserver
NAME ?= geoserver
GEOSERVER_VERSION ?= 2.21.1
GEOSERVER_VERSION_MAJOR := $(shell echo $(GEOSERVER_VERSION)|cut -d. -f1-2)
GEOSERVER_VERSION_2_21 ?= $(shell grep GEOSERVER_VERSION= 2.21/Dockerfile|grep -Eo '\d\.\d+\.\d')
GEOSERVER_VERSION_2_20 ?= $(shell grep GEOSERVER_VERSION= 2.20/Dockerfile|grep -Eo '\d\.\d+\.\d')
GEOSERVER_VERSION_2_19 ?= $(shell grep GEOSERVER_VERSION= 2.19/Dockerfile|grep -Eo '\d\.\d+\.\d')

default: build

build:
	docker build --rm \
		--tag "$(IMAGE):$(GEOSERVER_VERSION_MAJOR)" \
		--tag "$(IMAGE):$(GEOSERVER_VERSION)" \
		--build-arg GEOSERVER_VERSION=$(GEOSERVER_VERSION) $(GEOSERVER_VERSION_MAJOR)/

build-2.21:
	docker build --rm \
		--tag "$(IMAGE):2.21" \
		--tag "$(IMAGE):$(GEOSERVER_VERSION_2_21)" \
		--build-arg GEOSERVER_VERSION=$(GEOSERVER_VERSION_2_21) 2.21

build-2.20:
	docker build --rm \
		--tag "$(IMAGE):2.20" \
		--tag "$(IMAGE):$(GEOSERVER_VERSION_2_20)" \
		--build-arg GEOSERVER_VERSION=$(GEOSERVER_VERSION_2_20) 2.20

build-2.19:
	docker build --rm \
		--tag "$(IMAGE):2.19" \
		--tag "$(IMAGE):$(GEOSERVER_VERSION_2_19)" \
		--build-arg GEOSERVER_VERSION=$(GEOSERVER_VERSION_2_19) 2.19

build-2.18:
	docker build --rm \
		--tag "$(IMAGE):2.18.6" \
		--tag "$(IMAGE):2.18" \
		--build-arg GEOSERVER_VERSION=2.18.6 2.18/

build-2.17:
	docker build --rm \
		--tag "$(IMAGE):2.17.5" \
		--tag "$(IMAGE):2.17" \
		--build-arg GEOSERVER_VERSION=2.17.5 2.17/

build-2.16:
	docker build --rm \
		--tag "$(IMAGE):2.16.5" \
		--tag "$(IMAGE):2.16" \
		--build-arg GEOSERVER_VERSION=2.16.5 2.16/

build-2.15:
	docker build --rm \
		--tag "$(IMAGE):2.15.5" \
		--tag "$(IMAGE):2.15" \
		--build-arg GEOSERVER_VERSION=2.15.5 2.15/

build-maintenance:
	docker build --rm \
		--tag "$(IMAGE):$(GEOSERVER_MAINTENANCE_VERSION)" \
		--tag "$(IMAGE):$(GEOSERVER_MAINTENANCE_MAJOR)" \
		--build-arg GEOSERVER_VERSION=$(GEOSERVER_MAINTENANCE_VERSION) .

release:
	docker build --rm --no-cache --pull \
		--tag "$(IMAGE):$(GEOSERVER_VERSION)" \
		--tag "$(IMAGE):$(GEOSERVER_MAJOR)" \
		--build-arg GEOSERVER_VERSION=$(GEOSERVER_VERSION) .

shell:
	docker run -u $(shell echo $$RANDOM) --rm --name $(NAME) -it -v gs-test:/data/geoserver $(IMAGE):$(GEOSERVER_VERSION_MAJOR) bash

run:
	docker run -u $(shell echo $$RANDOM) --rm --name $(NAME) -p "8888:8080" -p "8443:8443" -v gs-test:/data/geoserver "$(IMAGE):$(GEOSERVER_VERSION_MAJOR)"

start:
	docker run -d --restart=always --name $(NAME) -p "8080:8080" -p "8443:8443" "$(IMAGE):$(GEOSERVER_VERSION_MAJOR)"

stop:
	docker stop $(NAME)
	docker rm $(NAME)

logs:
	docker logs -f $(NAME)
