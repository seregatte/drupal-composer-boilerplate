SHELL:=/bin/bash
D7_VERSION?=7.43
D8_VERSION?=8.1.1
DRUPAL_BOILERPLATE_HTTP_PORT?=8080
DRUPAL_BOILERPLATE_MYSQL_PORT?=33060
DRUPAL_BOILERPLATE_SSH_PORT?=22000
DRUPAL_BOILERPLATE_FOLDER?=../../../../
DRUPAL_BOILERPLATE_VERSION?=0.2
HOST?=drupal.dev
PROJECT_NAME?=drupal_boilerplate
DRUPAL_VERSION?=8
ENVIRONMENT?=development
CONTAINER?=ssh

all: server_up

server_up: requirements
	@export $$(cat .env | xargs) && cd infrastructure/environments/${ENVIRONMENT}/docker && docker-compose -f docker-compose.d$${DRUPAL_BOILERPLATE_DRUPAL_VERSION}.yml up -d

server_halt: requirements
	@export $$(cat .env | xargs) && cd infrastructure/environments/${ENVIRONMENT}/docker && docker-compose -f docker-compose.d$${DRUPAL_BOILERPLATE_DRUPAL_VERSION}.yml stop

server_start: requirements
	@export $$(cat .env | xargs) && cd infrastructure/environments/${ENVIRONMENT}/docker && docker-compose -f docker-compose.d$${DRUPAL_BOILERPLATE_DRUPAL_VERSION}.yml start

server_reload: requirements
	@export $$(cat .env | xargs) && cd infrastructure/environments/${ENVIRONMENT}/docker && docker-compose -f docker-compose.d$${DRUPAL_BOILERPLATE_DRUPAL_VERSION}.yml stop && docker-compose -f docker-compose.d$${DRUPAL_BOILERPLATE_DRUPAL_VERSION}.yml start

server_destroy: requirements
	@export $$(cat .env | xargs) && cd infrastructure/environments/${ENVIRONMENT}/docker && docker-compose -f docker-compose.d$${DRUPAL_BOILERPLATE_DRUPAL_VERSION}.yml stop && docker-compose -f docker-compose.d$${DRUPAL_BOILERPLATE_DRUPAL_VERSION}.yml rm

reinstall_drupal: requirements
	@export $$(cat .env | xargs) && chmod -Rf 777 public_html/sites/default/ && rm public_html/sites/default/settings.php && cp public_html/sites/default/default.settings.php public_html/sites/default/settings.php

install_drupal: requirements
	@chmod -R 777 public_html/sites/default && (test -d public_html/sites/default/files || mkdir public_html/sites/default/files) && chmod -R 777 public_html/sites/default/files
	@chmod -R 777 public_html/sites/default/ && cp public_html/sites/default/default.settings.php public_html/sites/default/settings.php && chmod -R 777 public_html/sites/default/settings.php
	@export $$(cat .env | xargs) && docker exec -it $${DRUPAL_BOILERPLATE_PROJECT_NAME}_$${DRUPAL_BOILERPLATE_DRUPAL_VERSION}_${CONTAINER} /bin/bash -c 'drush si --account-name=admin --account-pass=admin --db-url=mysql://drupal:drupal@mysql/drupal -y 2>/dev/null'
	@chmod -R 755 public_html/sites/default/settings.php

ssh: requirements
	@export $$(cat .env | xargs) && docker exec -it $${DRUPAL_BOILERPLATE_PROJECT_NAME}_$${DRUPAL_BOILERPLATE_DRUPAL_VERSION}_${CONTAINER} bash

sleep:
	@sleep 5

destroy: server_destroy

clean: destroy
	@export $$(cat .env | xargs) && docker rmi drupal-boilerplate/php:$${DRUPAL_BOILERPLATE_DRUPAL_VERSION}.$${DRUPAL_BOILERPLATE_VERSION} || true
	@export $$(cat .env | xargs) && docker rmi drupal-boilerplate/ssh:$${DRUPAL_BOILERPLATE_DRUPAL_VERSION}.$${DRUPAL_BOILERPLATE_VERSION} || true 
	@export $$(cat .env | xargs) && docker rmi drupal-boilerplate/fronttools:$${DRUPAL_BOILERPLATE_DRUPAL_VERSION}.$${DRUPAL_BOILERPLATE_VERSION} || true
	@export $$(cat .env | xargs) && docker volume rm $(docker volume ls -qf dangling=true) || TRUE
	@rm -Rf .env


requirements:
	@docker -v > /dev/null 2>&1 || { echo >&2 "I require docker but it's not installed. See : https://www.docker.com/"; exit 127;}
	@docker-compose -v > /dev/null 2>&1 || { echo >&2 "I require docker-compose but it's not installed. See : https://docs.docker.com/compose/install/"; exit 127;}
	@cat .env || make set_variable

set_variable:
	@echo "DRUPAL_BOILERPLATE_PROJECT_NAME=${PROJECT_NAME}" > .env
	@echo "DRUPAL_BOILERPLATE_HOST=${HOST}" >> .env
	@echo "DRUPAL_BOILERPLATE_DRUPAL_VERSION=${DRUPAL_VERSION}" >> .env
	@echo "DRUPAL_BOILERPLATE_VERSION=${DRUPAL_BOILERPLATE_VERSION}" >> .env
	@echo "DRUPAL_BOILERPLATE_FOLDER=${DRUPAL_BOILERPLATE_FOLDER}" >> .env
	@echo "DRUPAL_BOILERPLATE_HTTP_PORT=${DRUPAL_BOILERPLATE_HTTP_PORT}" >> .env
	@echo "DRUPAL_BOILERPLATE_MYSQL_PORT=${DRUPAL_BOILERPLATE_MYSQL_PORT}" >> .env
	@echo "DRUPAL_BOILERPLATE_SSH_PORT=${DRUPAL_BOILERPLATE_SSH_PORT}" >> .env
	@(test ${DRUPAL_VERSION} -eq 7 && echo "DRUPAL_BOILERPLATE_DOWNLOAD_VERSION=7.43" >> .env) || true
	@(test ${DRUPAL_VERSION} -eq 8 && echo "DRUPAL_BOILERPLATE_DOWNLOAD_VERSION=8.1.1" >> .env) || true

get_variable:
	@export $$(cat .env | xargs) && echo "DRUPAL_BOILERPLATE_PROJECT_NAME="$$DRUPAL_BOILERPLATE_PROJECT_NAME
	@export $$(cat .env | xargs) && echo "DRUPAL_BOILERPLATE_HOST="$$DRUPAL_BOILERPLATE_HOST
	@export $$(cat .env | xargs) && echo "DRUPAL_BOILERPLATE_DRUPAL_VERSION="$$DRUPAL_BOILERPLATE_DRUPAL_VERSION
	@export $$(cat .env | xargs) && echo "DRUPAL_BOILERPLATE_VERSION="$$DRUPAL_BOILERPLATE_VERSION
	@export $$(cat .env | xargs) && echo "DRUPAL_BOILERPLATE_FOLDER="$$DRUPAL_BOILERPLATE_FOLDER
	@export $$(cat .env | xargs) && echo "DRUPAL_BOILERPLATE_HTTP_PORT="$$DRUPAL_BOILERPLATE_HTTP_PORT
	@export $$(cat .env | xargs) && echo "DRUPAL_BOILERPLATE_MYSQL_PORT="$$DRUPAL_BOILERPLATE_MYSQL_PORT
	@export $$(cat .env | xargs) && echo "DRUPAL_BOILERPLATE_SSH_PORT="$$DRUPAL_BOILERPLATE_SSH_PORT
	@export $$(cat .env | xargs) && echo "DRUPAL_BOILERPLATE_DOWNLOAD_VERSION="$$DRUPAL_BOILERPLATE_DOWNLOAD_VERSION

test_server_up:
	@export $$(cat .env | xargs) && cd infrastructure/environments/${ENVIRONMENT}/docker && docker-compose -f docker-compose.test.yml up -d
	@sleep 3

test_server_destroy:
	@export $$(cat .env | xargs) && cd infrastructure/environments/${ENVIRONMENT}/docker && docker-compose -f docker-compose.test.yml kill	&& docker-compose -f docker-compose.test.yml rm -f

help:
	@echo "make server_up 			-> Up and provisione docker container."
	@echo "make server_destroy 		-> Destroy docker container."
	@echo "make server_halt 		-> Halt docker container."
	@echo "make server_start 		-> Start container already provisioned"
	@echo "make server_reload 		-> Halt and start container already provisioned"
	@echo "make destroy_install_all	-> Rebuild system an run all tests."
	@echo "make reinstall_drupal		-> Rewrite settings.php on default folder."
	@echo "make install_drupal		-> Run process to install drupal on container."
	@echo "make ssh			-> Enable us to run commands inside a container."
	@echo "make help 			-> Show that message list."
	@echo "make test_help 			-> List commands that doesn't have documentation yet."

test_help:
	@join -v 1 <(cat Makefile | grep ^[a-z][^\w]*: | cut -f1 -d":" | sort) <(make help | cut -f2 -d" " | sort)
