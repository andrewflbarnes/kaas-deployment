#!/usr/bin/env make

include .env
export $(shell sed 's/=.*//' .env)

.PHONY: help start stop db-clean db-build all

help:
	@echo "  make help      - show this help text"
	@echo "  make start     - an alias for docker-compose up -d"
	@echo "  make stop      - an alias for docker-compose stop"
	@echo "  ** The below commands are dependent on kings-results-service being cloned on .. **"
	@echo "  make db-clean  - clears down the kaas-database"
	@echo "  make db-build  - provisions the kaas-database and loads it with test data"
	@echo "  make all       - an alias for start and db-build"

all: start db-build

start:
	docker-compose up -d

stop:
	docker-compose stop

define db-op
	cd ../kings-results-service; \
		mvn -pl :database-scripts -Ddb.port=$$db_port -Pdb-$(strip $1)
endef

db-build:
	$(call db-op, migrate)
	$(call db-op, load-test)

db-clean:
	$(call db-op, clean)
