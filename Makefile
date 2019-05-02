DOCKER_IMAGE := gitlab/gitlab-ce

all: build

help:
	@echo ""
	@echo "-- Help Menu"
	@echo ""
	@echo "   1. make bash          - build the gitlab image"
	@echo "   2. make version       - start gitlab"
	@echo "   3. make reconfigure   - reconfigure settings gitlab"
	@echo "   4. make backup        - backups gitlab"
	@echo "   5. make start         - start containers"
	@echo "   6. make stop          - stop containers"
	@echo "   7. make down          - down containers"
	@echo "   8. make logs          - view logs"

bash:
	@source .env
	@docker run --rm --net=host -it gitlab/gitlab-ce /bin/sh

version:
	@docker run --rm --net=host -it postgres:alpine psql --version

reconfigure:
	@docker-compose exec gitlab gitlab-ctl reconfigure

backup:
	@docker-compose exec gitlab gitlab-rake gitlab:backup:create

start:
	@echo "Starting gitlab containers..."
	@docker-compose up -d --build >/dev/null
	@echo "Please be patient. This could take a while..."
	@echo "GitLab will be available at http://localhost:10080"
	@echo "Type 'make logs' for the logs"	

stop:
	@echo "Stopping gitlab containers..."
	@docker-compose stop >/dev/null

down:
	@echo "Down gitlab containers..."
	@docker-compose down >/dev/null

logs:
	@docker logs -f --tail="20" gitlab_server
