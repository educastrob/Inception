LOGIN := edcastro
DOMAIN_NAME := $(LOGIN).42.fr
PATH_TO_VOLUME := /home/$(LOGIN)/data
DOCKER_COMPOSE = sudo docker compose -f ./srcs/docker-compose.yml
PROJECT_ENV_URL = https://raw.githubusercontent.com/educastrob/inception/refs/heads/main/srcs

export PATH_TO_VOLUME

all: build

install:
	curl -fsSL https://get.docker.com -o get-docker.sh
	sudo sh ./get-docker.sh && rm ./get-docker.sh

	sudo usermod -aG docker $$(whoami)
	echo "%docker ALL=(ALL) NOPASSWD: /home/$$(whoami)/data/*" | sudo tee /etc/sudoers.d/docker
	@echo ""
	@docker --version
	@echo ""
	@docker compose version
	@echo ""

build:
	@echo "Getting the .env file..."
	@if [ ! -f ./srcs/.env ]; then \
		curl -fsSL "$(PROJECT_ENV_URL)/.env" -o ./srcs/.env; \
		else echo ".env file already exists!"; \
	fi
	@echo ""
	@echo ""

	sudo mkdir -p ${PATH_TO_VOLUME}/mariadb
	sudo mkdir -p ${PATH_TO_VOLUME}/wordpress

	@echo "Add $(DOMAIN_NAME) in /etc/hosts..."
		@if ! grep -q "$(DOMAIN_NAME)" /etc/hosts; then \
		echo "127.0.0.1 $(DOMAIN_NAME)" | sudo tee -a /etc/hosts > /dev/null; \
		else echo "$(DOMAIN_NAME).42.fr already exists in /etc/hosts!"; \
	fi
	@$(DOCKER_COMPOSE) up --build -d

kill:
	@$(DOCKER_COMPOSE) kill

down:
	@$(DOCKER_COMPOSE) down

clean:
	@containers_before=$$(docker ps -aq | wc -l); \
	echo "Number of containers in execution: $$containers_before";
	@$(DOCKER_COMPOSE) down -v > /dev/null
	sudo rm -rf ${PATH_TO_VOLUME}/mariadb;
	sudo rm -rf ${PATH_TO_VOLUME}/wordpress;
	@echo "Removing $(DOMAIN_NAME) from /etc/hosts...";
    
	@if grep -q "$(DOMAIN_NAME)" /etc/hosts; then \
        sudo sed -i "/$(DOMAIN_NAME)/d" /etc/hosts; \
    else echo "$(DOMAIN_NAME) not found in /etc/hosts."; \
    fi

restart: clean build

.PHONY: build clean down kill restart
