#!/usr/bin/env make

include .env
export $(shell sed 's/=.*//' .env)

.DEFAULT_GOAL = help

tmpdir = tmp
docker_opts = -f docker/docker-compose.yml
backend_local = $(tmpdir)/backend
backend_repo = git@github.com:andrewflbarnes/kings-results-service

VPATH = .:$(tmpdir)

.PHONY: help
help:
	@echo "  make help           - show this help text"
	@echo "  make build          - builds the kaas-proxy in docker/proxy"
	@echo "  make all            - an alias for start and db-build"
	@echo "  make start          - an alias for docker-compose up -d"
	@echo "  make status         - an alias for docker-compose ps"
	@echo "  make stop           - an alias for docker-compose stop"
	@echo "  make kill           - an alias for docker-compose rm -sf"
	@echo "  make backend-update - pulls the latest version of the backend used for db commands"
	@echo "  make db-clean       - clears down the kaas-database"
	@echo "  make db-build       - provisions the kaas-database and loads it with test data"

.PHONY: build
build:
	docker build -t andrewflbarnes/kaas-proxy docker/proxy

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
	$(call db-op, migrate)
	$(call db-op, load-test)

db-clean: backend
	$(call db-op, clean)

.PHONY: backend-update
backend-update: backend
	cd $(backend_local) && git checkout master && git pull

backend:
	git clone $($@_repo) $(tmpdir)/$@
