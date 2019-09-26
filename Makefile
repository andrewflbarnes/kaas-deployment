#!/usr/bin/env make -f

include .env
export $(shell sed 's/=.*//' .env)

.DEFAULT_GOAL = help
.SILENT:

tmpdir = tmp
docker_opts = -f docker/docker-compose.yml
backend_local = $(tmpdir)/backend
backend_repo = git@github.com:andrewflbarnes/kings-results-service

VPATH = .:$(tmpdir)

define helptext
echo " \
 make help           - show this help text \
\n make clean          - cleans any temporary directories \
\n make build          - builds the kaas-proxy in docker/proxy \
\n make all            - an alias for start and db-build \
\n make start          - an alias for docker-compose up -d \
\n make status         - an alias for docker-compose ps \
\n make stop           - an alias for docker-compose stop \
\n make kill           - an alias for docker-compose rm -sf \
\n make backend-update - pulls the latest version of the backend used for db commands \
\n make db-clean       - clears down the kaas-database \
\n make db-build       - provisions the kaas-database and loads it with test data \
"
endef

.PHONY: help
help:
	@$(call helptext)

.PHONY: clean
clean:
	rm -rf $(tmpdir)

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
