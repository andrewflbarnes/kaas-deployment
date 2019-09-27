#!/usr/bin/env make -f

include .env
export $(shell sed 's/=.*//' .env)

.DEFAULT_GOAL = help
.SILENT:

tmpdir = tmp
backend_local = $(tmpdir)/backend
backend_repo = git@github.com:andrewflbarnes/kings-results-service
ifeq ($(CIRCLECI),true)
docker_opts = -f .circleci/docker-compose.yml
else
docker_opts = -f docker/docker-compose.yml
endif

VPATH = .:$(tmpdir)
SHELL = /bin/bash

.PHONY: help
help:
	echo " help           - show this help text"
	echo " clean          - cleans any temporary directories"
	echo " build          - builds the kaas-proxy in docker/proxy"
	echo " all            - an alias for start and db-build"
	echo " start          - an alias for docker-compose up -d"
	echo " status         - an alias for docker-compose ps"
	echo " stop           - an alias for docker-compose stop"
	echo " kill           - an alias for docker-compose rm -sf"
	echo " backend-update - pulls the latest version of the backend used for db commands"
	echo " db-clean       - clears down the kaas-database"
	echo " db-build       - provisions the kaas-database and loads it with test data"

.PHONY: clean
clean:
	rm -rf $(tmpdir)

.PHONY: build circleci
build:
	docker build -t andrewflbarnes/kaas-proxy docker/proxy

circleci:
	sed 's/##version##/$(version)/g' .circleci/Dockerfile.template > .circleci/Dockerfile
	docker build -t andrewflbarnes/kaas-backend:$(version) -f .circleci/Dockerfile docker

.PHONY: all start status stop kill
all: start db-build

define docker
docker-compose $(docker_opts) $1
endef

start:
	$(call docker, up -d)

status:
	$(call docker, ps)

stop:
	$(call docker, stop)

kill:
	$(call docker, rm -sf)

define db-op
cd $(backend_local); \
mvn -pl :database-scripts -Ddb.port=$$db_port -Pdb-$(strip $1)
endef

.PHONY: db-clean db-build
db-build: backend
ifneq ($(CIRCLECI),true)
	$(call db-op, migrate)
	$(call db-op, load-test)
else
	docker run \
		--name provision \
		--network kaas-deploy \
		--rm \
		maven:3-jdk-8-alpine \
		bash -c "$$(cat docker/database/provision)"
endif

db-clean: backend
	$(call db-op, clean)

.PHONY: backend-update
backend-update: backend
	cd $(backend_local) && git checkout master && git pull

backend:
ifneq ($(CIRCLECI),true)
	git clone $($@_repo) $(tmpdir)/$@
endif
