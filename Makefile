COMPOSE_PROJECT_NAME=dummy
DOCKER_COMPOSE=COMPOSE_PROJECT_NAME=${COMPOSE_PROJECT_NAME} docker-compose -f .docker/docker-compose.yml --env-file .docker/.env --project-directory .

# If the first argument is "composer"...
ifeq (composer,$(firstword $(MAKECMDGOALS)))
  # use the rest as arguments for "COMPOSER"
  COMPOSER_ARGS := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
  # ...and turn them into do-nothing targets
  $(eval $(COMPOSER_ARGS):;@:)
endif
composer:
	${DOCKER_COMPOSE} run --rm composer $(COMPOSER_ARGS)
.PHONY: composer


vendor: composer.json composer.lock
	${DOCKER_COMPOSE} run --rm composer install


composer.lock: composer.json
	${DOCKER_COMPOSE} run --rm composer install


# https://stackoverflow.com/a/14061796
# If the first argument is "dc"...
ifeq (dc,$(firstword $(MAKECMDGOALS)))
  # use the rest as arguments for "dc"
  DC_ARGS := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
  # ...and turn them into do-nothing targets
  $(eval $(DC_ARGS):;@:)
endif
dc:
	${DOCKER_COMPOSE} $(DC_ARGS)
.PHONY: dc


build:
	${DOCKER_COMPOSE} build
.PHONY: build


stop:
	${DOCKER_COMPOSE} stop
.PHONY: stop


down:
	${DOCKER_COMPOSE} down
.PHONY: down


wordpress:
	${DOCKER_COMPOSE} up --detach wordpress
.PHONY: wordpress


wp-cli:
	${DOCKER_COMPOSE} run --rm wp-cli
.PHONY: wp-cli


db-dump:
	${DOCKER_COMPOSE} run --rm wp-cli wp db export tests/_data/dump.sql
.PHONY: db-dump


# If the first argument is "codecept"...
ifeq (codecept,$(firstword $(MAKECMDGOALS)))
  # use the rest as arguments for "codecept"
  CODECEPT_ARGS := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
  # ...and turn them into do-nothing targets
  $(eval $(CODECEPT_ARGS):;@:)
endif
codecept:
	${DOCKER_COMPOSE} up -d codecept
	${DOCKER_COMPOSE} exec --workdir /var/www/html/wp-content/plugins/${COMPOSE_PROJECT_NAME}/ codecept codecept $(CODECEPT_ARGS)
.PHONY: test-%
