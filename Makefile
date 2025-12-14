USER = edcastro
WORDPRESS_DIRECTORY =/home/$(USER)/data/wordpress
MARIADB_DIRECTORY = /home/$(USER)/data/mariadb
COMPOSE_PATH=./srcs/docker-compose.yml
DOCKER_EXEC=docker-compose -f $(COMPOSE_PATH)

all: config up

# setup to prepare the environment before the containers go up

config:

	@echo "Getting the .env file..."
	@if [ ! -f ./srcs/.env ]; then \
		wget -P ./srcs https://raw.githubusercontent.com/educastrob/Inception/master/srcs/.env; \
		else echo ".env file already exists!"; \
	fi

	@echo "Add edcastro.42.fr in /etc/hosts..."
		@if ! grep -q "edcastro.42.fr" /etc/hosts; then \
		echo "127.0.0.1 $(USER).42.fr" | sudo tee -a /etc/hosts > /dev/null; \
		else echo "edcastro.42.fr already exists in /etc/hosts!"; \
	fi

	@echo "Creating the data directories..."
	@if [ ! -d "$(MARIADB_DIRECTORY)" ]; then \
		sudo mkdir -p $(MARIADB_DIRECTORY); \
		else echo "MariaDB data directory already exists!"; \
	fi

	@if [ ! -d "$(WORDPRESS_DIRECTORY)" ]; then \
		sudo mkdir -p $(WORDPRESS_DIRECTORY); \
		else echo "Wordpress data directory already exists!"; \
	fi

## rules to manipulate containers

build:
	@echo "Building the containers..."
	$(DOCKER_EXEC) build

up: build
	@echo "Starting the containers..."
	$(DOCKER_EXEC) up -d

down:
	@echo "Stopping the containers..."
	$(DOCKER_EXEC) down

ps:
	@echo "Showing the containers..."
	$(DOCKER_EXEC) ps

## rules to clean the environment and remove the containers

clean:
	@echo "Cleaning the containers..."
	$(DOCKER_EXEC) down --rmi all --volumes

fclean: clean
	@echo "Removing the .env file..."
	rm ./srcs/.env
	sudo sed -i '/edcastro\.42\.fr/d' /etc/hosts
	@echo "Removing the data directories..."
	@if [ -d "/home/edcastro/data" ]; then \
		sudo rm -rf /home/edcastro/data; \
	fi
	docker system prune -a --volumes -f

re: fclean all

.PHONY: all config build up down ps prune clean fclean re