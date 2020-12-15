CURRENT_DIR = $(shell pwd)
# Docker Information
DOCKER_NAME ?= avdteam/vscode
FLAVOR ?= latest
BRANCH ?= $(shell git symbolic-ref --short HEAD)
# New Flavor creation
TEMPLATE ?= _template
UID ?= 1000
GID ?= 1000
VSCODE_PORT ?= 8080
LOCAL_AVD_PATH ?= $(HOME)/Projects/arista-ansible
AVD_MODE ?= demo

.PHONY: build
build: ## Build docker image
	docker build -t $(DOCKER_NAME):$(FLAVOR) docker

clean:
	docker ps -q | xargs docker rm -f

vanilla: ## Run vanilla instance
	docker run --rm -it -d -v /var/run/docker.sock:/var/run/docker.sock \
			-e AVD_GIT_USER=titom73 \
			-e AVD_GIT_EMAIL=tom@inetsix.net \
			-p $(VSCODE_PORT):8080 \
			$(DOCKER_NAME):$(FLAVOR)

demo: ## Run vanilla instance
	docker run --rm -it -d -e AVD_MODE=$(AVD_MODE) \
			-v /var/run/docker.sock:/var/run/docker.sock \
			-p $(VSCODE_PORT):8080 \
			-v ~/.gitconfig:/home/avd/.gitconfig \
			$(DOCKER_NAME):$(FLAVOR)

share-only: ## Run instance with AVD volume shared and user-extensions
	docker run --rm -it -d -v $(LOCAL_AVD_PATH):/home/avd/arista-ansible \
			-v /var/run/docker.sock:/var/run/docker.sock \
			-p $(VSCODE_PORT):8080 \
			-v ~/.gitconfig:/home/avd/.gitconfig \
			$(DOCKER_NAME):$(FLAVOR)

share-with-extensions: ## Run instance with AVD volume shared and user-extensions
	docker run --rm -it -d -e AVD_USER_EXTENSIONS_FILE=my_settings/user-extensions.txt \
			-v $(CURRENT_DIR)/tests:/home/avd/my_settings \
			-v $(LOCAL_AVD_PATH):/home/avd/arista-ansible \
			-v /var/run/docker.sock:/var/run/docker.sock \
			-p $(VSCODE_PORT):8080 \
			-v ~/.gitconfig:/home/avd/.gitconfig \
			$(DOCKER_NAME):$(FLAVOR)