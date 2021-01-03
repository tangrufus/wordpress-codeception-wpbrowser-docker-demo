COMPOSE_PROJECT_NAME=dummy
DOCKER_COMPOSE=COMPOSE_PROJECT_NAME=${COMPOSE_PROJECT_NAME} docker-compose -f .docker/docker-compose.yml --env-file .docker/.env --project-directory .

.PHONY: dc stop down composer web wp-cli test test-% db-dump

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

stop:
	${DOCKER_COMPOSE} stop

down:
	${DOCKER_COMPOSE} down

composer:
	${DOCKER_COMPOSE} run --rm composer

wordpress:
	${DOCKER_COMPOSE} up --detach wordpress

wp-cli:
	${DOCKER_COMPOSE} run --rm wp-cli

test:
	make test-unit
	make test-wpunit
	make test-functional
	make test-acceptance

test-%:
	${DOCKER_COMPOSE} run --rm test $*

db-dump:
	${DOCKER_COMPOSE} run --rm wp-cli wp db export tests/_data/dump.sql
