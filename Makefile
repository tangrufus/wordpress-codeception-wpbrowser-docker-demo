# https://clarkgrubb.com/makefile-style-guide#toc2
MAKEFLAGS += --warn-undefined-variables
SHELL := bash
# macOS hasn't support GNU Make 3.82 yet
# .SHELLFLAGS := -eu -o pipefail -c
.DEFAULT_GOAL := help
.DELETE_ON_ERROR:
.SUFFIXES:

# Colors
green  := \033[32m
yellow := \033[1m
reset  := \033[0m

# Load environment variables
env = .docker/.env.local
ifeq ("$(wildcard $(env))","")
    env = .docker/.env
endif
include $(env)
export $(shell sed 's/=.*//' $(env))

docker_compose = COMPOSE_PROJECT_NAME=${COMPOSE_PROJECT_NAME} USER="$(shell id -u):$(shell id -g)" docker-compose -f .docker/docker-compose.yml --env-file $(env) --project-directory .
docker_compose_workdir_flag = --workdir /var/www/html/wp-content/plugins/${COMPOSE_PROJECT_NAME}/

d_volumes = d-volume-wordpress d-volume-wordpress-db
d_networks = d-network-default d-network-workspace d-network-codecept
composer_services = composer
wordpress_services = wordpress wp db
codecept_services = codecept db-codecept chrome

.PHONY: init
init: setup ci ##@Setup@ Setup and run all service; Reset wp db from db dump
	$(MAKE) wordpress
	$(MAKE) wp-db-import
	@printf "\n\n"
	@printf "%0.s-" {0..48}
	@printf "\n"
	@printf "$(green)Success:$(reset) WordPress and test services are ready.\n"
	@printf "$(green)Success:$(reset) All test suites passed\n"
	@printf "$(green)Success:$(reset) Imported from '$(yellow)${MYSQL_DUMP}$(reset)'.\n"
	@printf "$(green)Success:$(reset) Listening on $(yellow)http://localhost:${WEB_PUBLISHED_PORT}$(reset)\n"

.PHONY: setup
setup: setup-composer setup-wordpress setup-codecept ##@Setup@ Pull and build all services

.PHONY: setup-composer ##@Setup@ Pull and build composer service and its dependencies
setup-composer: d-volumes d-networks dc-pull-composer dc-build-composer;

.PHONY: setup-% ##@Setup@ Pull and build certain service and its dependencies
setup-%: d-volumes d-networks dc-pull-% dc-build-% setup-composer;

.PHONY: d-volumes
d-volumes: $(d_volumes) ##@Setup@ Create docker columns

.PHONY: d-volume-%
d-volume-%:
	docker volume create --name=${COMPOSE_PROJECT_NAME}-$*

.PHONY: d-networks
d-networks: $(d_networks) ##@Setup@ Create docker columns

.PHONY: d-network-%
d-network-%:
	docker network create ${COMPOSE_PROJECT_NAME}_$*


.docker/.env.local: .docker/.env ##@Setup@ Generate .env.local to override environment variables
	cp .docker/.env .docker/.env.local


runnable_targets += dc
.PHONY: dc
dc: ##@Docker Compose@ Run docker-compose commands with project configs
	$(docker_compose) $(run_args)


.PHONY: dc-build
dc-build: ##@Docker Compose@ Build images for all services
	$(docker_compose) build --parallel

.PHONY: dc-build-%
dc-build-%: ##@Docker Compose@ Build images for specific service and its dependencies
	$(docker_compose) build --parallel $($*_services)


.PHONY: dc-pull
dc-pull: ##@Docker Compose@ Pull images for all services
	$(docker_compose) pull

.PHONY: dc-pull-%
dc-pull-%: ##@Docker Compose@ Pull images for specific service and its dependencies
	$(docker_compose) pull $($*_services)


runnable_targets += composer
.PHONY: composer
composer: ##@Composer@ Run composer commands via docker-compose service
	$(docker_compose) run --rm composer $(run_args)


vendor: composer.json composer.lock ##@Composer@ Run composer install
	$(docker_compose) run --rm composer composer install
	@touch $@


.PHONY: wordpress
wordpress: vendor ##@WordPress@ Start wordpress service in detached mode
	$(docker_compose) up --detach wordpress
	@printf "\n\n$(green)Success:$(reset) Listening on $(yellow)http://localhost:${WEB_PUBLISHED_PORT}$(reset)\n"


runnable_targets += wp
.PHONY: wp
wp: vendor ##@WordPress@ Run wp cli commands on wordpress service
	$(docker_compose) run --rm $(docker_compose_workdir_flag) $@ wp $(run_args)


.PHONY: wp-db-export ${MYSQL_DUMP}
wp-db-export: ##@WordPress@ Export wordpress service database
	$(docker_compose) run --rm $(docker_compose_workdir_flag) $@ wp wp db export ${MYSQL_DUMP}
${MYSQL_DUMP}:
	$(docker_compose) run --rm $(docker_compose_workdir_flag) $@ wp wp db export ${MYSQL_DUMP}


.PHONY: wp-db-import
wp-db-import: ##@WordPress@ Import database dump into wordpress service
	$(docker_compose) run --rm $(docker_compose_workdir_flag) $@ wp wp db import $(MYSQL_DUMP)


runnable_targets += codecept
.PHONY: codecept
codecept: vendor ##@Codeception@ Run codecept commands via docker-compose service
	$(docker_compose) up --detach $@
	$(docker_compose) exec -T $(docker_compose_workdir_flag) $@ codecept $(run_args)


.PHONY: codecept-run
codecept-run: vendor ##@Codeception@ Run all codecept test suites
	$(docker_compose) up --detach codecept
	$(docker_compose) exec -T $(docker_compose_workdir_flag) codecept codecept run unit
	$(docker_compose) exec -T $(docker_compose_workdir_flag) codecept codecept run wpunit
	$(docker_compose) exec -T $(docker_compose_workdir_flag) codecept codecept run functional
	$(docker_compose) exec -T $(docker_compose_workdir_flag) codecept codecept run acceptance
	@printf "\n\n$(green)Success:$(reset) All test suites passed\n"


.PHONY: codecept-run
ci: setup-composer ci-setup-codecept vendor ##@Codeception@ Run all codecept test suites
	$(docker_compose) exec -T $(docker_compose_workdir_flag) codecept codecept run unit
	$(docker_compose) exec -T $(docker_compose_workdir_flag) codecept codecept run wpunit
	$(docker_compose) exec -T $(docker_compose_workdir_flag) codecept codecept run functional
	$(docker_compose) exec -T $(docker_compose_workdir_flag) codecept codecept run acceptance
	@printf "\n\n$(green)Success:$(reset) All test suites passed\n"

.PHONY: ci-setup-codecept
ci-setup-codecept: setup-codecept;
	$(docker_compose) up --detach $(codecept_services)



# https://stackoverflow.com/a/30796664
HELP_FUN = \
    %help; while(<>){push@{$$help{$$2//'options'}},[$$1,$$3] \
    if/^([\w-_\%\s\/\.]+)\s*:.*\#\#(?:@([\w-\s]+)(?:@))?\s(.*)$$/}; \
    print"    $$_:\n", map"    $(green)$$_->[0]$(reset)".(" "x(19-length($$_->[0])))."$$_->[1]\n",\
    @{$$help{$$_}},"\n" for keys %help; \

.PHONY: help
help: ##@Miscellaneous@ Show this help
	@printf "\n$(yellow)USAGE$(reset)\n"
	@printf "    make [--] <target> [run_args...]\n"
	@printf "\n$(yellow)EXAMPLES$(reset)\n"
	@printf "    $$ make setup\n"
	@printf "    $$ make vendor\n"
	@printf "    $$ make composer require php:^7.4\n"
	@printf "    $$ make -- composer update --with-all-dependencies\n"
	@printf "    $$ make wordpress\n"
	@printf "    $$ make wp cli info\n"
	@printf "    $$ make -- wp plugin list --format=csv\n"
	@printf "    $$ make test\n"
	@printf "    $$ make codecept run acceptance\n"
	@printf "    $$ make -- codecept run functional --debug\n"
	@printf "    $$ make dc stop\n"
	@printf "    $$ make dc-build\n"
	@printf "    $$ make dc exec db sh\n"
	@printf "\n$(yellow)TARGETS$(reset)\n"
	@perl -e '$(HELP_FUN)' $(MAKEFILE_LIST)


# If the first argument is one of "runnable_targets"
ifeq ($(firstword $(MAKECMDGOALS)),$(findstring $(firstword $(MAKECMDGOALS)),$(runnable_targets)))
    # use the rest as arguments
    run_args := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
    # turn them into do-nothing targets; override exisiting commands
    $(eval $(subst :,,$(run_args)):;@:)
endif
