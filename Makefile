#!/usr/bin/env make

include .env
export $(shell sed -n '/^#/!s/=.*//p' .env)

.PHONY: help start stop db-clean db-build all

help:
	@echo "  make help      - show this help text"
	@echo "  make start     - an alias for docker-compose up -d"
	@echo "  make stop      - an alias for docker-compose stop"
	@echo "  ** The below commands are dependent on kings-results-service being cloned on .. **"
	@echo "  make db-clean  - clears down the kaas-database"
	@echo "  make db-build  - provisions the database and loads it with test data"
	@echo "  make all       - an alias for start and build"

all: start db-build

start:
	docker-compose up -d

stop:
	docker-compose stop

db-build:
	cd ../kings-results-service; \
		mvn -pl :database-scripts -Ddb.port=$$db_port -Pdb-migrate
	cd ../kings-results-service; \
		mvn -pl :database-scripts -Ddb.port=$$db_port -Pdb-load-test

db-clean:
	cd ../kings-results-service; \
		mvn -pl :database-scripts -Ddb.port=$$db_port -Pdb-clean
