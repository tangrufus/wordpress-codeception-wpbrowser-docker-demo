DOCKER_COMPOSE=docker-compose -f .docker/docker-compose.yml --env-file .docker/.env --project-directory .

.PHONY: dc down web wp-cli

# https://stackoverflow.com/questions/2214575/passing-arguments-to-make-run
# If the first argument is "dc"...
ifeq (dc,$(firstword $(MAKECMDGOALS)))
  # use the rest as arguments for "dc"
  DC_ARGS := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
  # ...and turn them into do-nothing targets
  $(eval $(DC_ARGS):;@:)
endif
dc:
	${DOCKER_COMPOSE} $(DC_ARGS)

down:
	${DOCKER_COMPOSE} down

composer:
	${DOCKER_COMPOSE} run --rm composer

web:
	${DOCKER_COMPOSE} up --detach web

wp-cli:
	${DOCKER_COMPOSE} run --rm wp-cli
