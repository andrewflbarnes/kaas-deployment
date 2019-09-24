#!/usr/bin/env make

include .env
export $(shell sed 's/=.*//' .env)

.PHONY: help help-main help-nginx
.PHONY: all kill
.PHONY: start stop
.PHONY: db-clean db-build

help: help-main help-nginx

help-main:
	@echo "  make help      - show this help text"
	@echo "  make start     - an alias for docker-compose up -d"
	@echo "  make stop      - an alias for docker-compose stop"
	@echo "  make kill      - an alias for docker-compose rm -sf"
	@echo "  ** The below commands are dependent on kings-results-service being cloned on .. **"
	@echo "  make db-clean  - clears down the kaas-database"
	@echo "  make db-build  - provisions the kaas-database and loads it with test data"
	@echo "  make all       - an alias for start and db-build"

help-nginx:
	@echo "  The nginx reverse proxy will only redirect to the kaas services if the target server"
	@echo "  is kaas.com"
	@echo "  Ensure this is added to your hosts file or modify the nginx.conf"

all: start db-build help-nginx

start:
	docker-compose up -d

stop:
	docker-compose stop

kill:
	docker-compose rm -sf

define db-op
	cd ../kings-results-service; \
		mvn -pl :database-scripts -Ddb.port=$$db_port -Pdb-$(strip $1)
endef

db-build:
	$(call db-op, migrate)
	$(call db-op, load-test)

db-clean:
	$(call db-op, clean)
