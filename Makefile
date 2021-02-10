GEOSERVER_MAJOR ?= 2.18
GEOSERVER_MINOR ?= 2
GEOSERVER_VERSION ?= $(GEOSERVER_MAJOR).$(GEOSERVER_MINOR)
ORG ?= meteofi
NAME ?= geoserver
IMAGE ?= $(ORG)/$(NAME)

default: build

build:
	docker build --rm \
		--tag "$(IMAGE):$(GEOSERVER_VERSION)" \
		--tag "$(IMAGE):$(GEOSERVER_MAJOR)" \
		--build-arg GEOSERVER_VERSION=$(GEOSERVER_VERSION) .

release:
	docker build --rm --no-cache --pull \
		--tag "$(IMAGE):$(GEOSERVER_VERSION)" \
		--tag "$(IMAGE):$(GEOSERVER_MAJOR)" \
		--build-arg GEOSERVER_VERSION=$(GEOSERVER_VERSION) .

shell:
	docker run --rm --name $(NAME) -p "8080:8080" -p "8443:8443" -it "$(IMAGE):$(GEOSERVER_VERSION)" bash

run:
	docker run --rm --name $(NAME) -p "8080:8080" -p "8443:8443" "$(IMAGE):$(GEOSERVER_VERSION)"

start:
	docker run -d --restart=always --name $(NAME) -p "8080:8080" -p "8443:8443" "$(IMAGE):$(GEOSERVER_VERSION)"

stop:
	docker stop $(NAME)
	docker rm $(NAME)

logs:
	docker logs -f $(NAME)
