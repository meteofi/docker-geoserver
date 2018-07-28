GEOSERVER_MAJOR ?= 2.13
GEOSERVER_MINOR ?= 2
GEOSERVER_VERSION ?= $(GEOSERVER_MAJOR).$(GEOSERVER_MINOR)
ORG ?= meteofi
NAME ?= geoservertest
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
	docker run --rm --name $(NAME) -p "8888:8080" -it "$(IMAGE):$(GEOSERVER_VERSION)" bash


run:
	docker run --rm --name $(NAME) -p "8888:8080" "$(IMAGE):$(GEOSERVER_VERSION)"

start:
	docker run -d --name $(NAME) -p "8888:8080" "$(IMAGE):$(GEOSERVER_VERSION)"

stop:
	docker stop $(NAME)
	docker rm $(NAME)

logs:
	docker logs -f $(NAME)
