#!/bin/bash

DOCKER_SOCKET=/var/run/docker.sock
DOCKER_GROUP=docker
USER=avd

# Reconfigure AVD User id if set by user
if [ ! -z "${AVD_UID}" ]; then
  echo "Update uid for user avd with ${AVD_UID}"
  usermod -u ${AVD_UID} avd
fi
if [ ! -z "${AVD_GID}" ]; then
  echo "Update gid for group avd with ${AVD_GID}"
  groupmod -g ${AVD_GID} avd
fi

# Update gitconfig with username and email
if [ -n "${AVD_GIT_USER}" ]; then
  echo "Update gitconfig with ${AVD_GIT_USER}"
  sed -i "s/USERNAME/${AVD_GIT_USER}/g" ${HOME}/.gitconfig
else
  sed -i "s/USERNAME/AVD Code USER/g" ${HOME}/.gitconfig
fi
if [ -n "${AVD_GIT_EMAIL}" ]; then
  echo "Update gitconfig with ${AVD_GIT_EMAIL}"
  sed -i "s/USER_EMAIL/${AVD_GIT_EMAIL}/g" ${HOME}/.gitconfig
else
  sed -i "s/USER_EMAIL/avd-code@arista.com/g" ${HOME}/.gitconfig
fi

# Configure local docker socket permissions
if [ -S ${DOCKER_SOCKET} ]; then
    sudo chmod 666 /var/run/docker.sock &>/dev/null
fi

export PATH=$PATH:/home/avd/.local/bin
export LC_ALL=C.UTF-8

cd ${HOME}

# Start clone process if running in DEMO/ATD mode
if [  "${AVD_MODE}" == "demo" ]; then
  echo "Running in demo/ATD mode"
  echo "  * Getting repositories from Github"
  curl -fsSL https://get.avd.sh/ | sh
elif [ "${AVD_MODE}" == "toi" ]; then
  echo "Running in TOI mode"
  echo "  * Getting repositories from Github"
  curl -fsSL https://get.avd.sh/toi/install.sh | sh
fi

# Install user repositories from ${AVD_USER_REPOS}
if [ -f "${AVD_USER_REPOS}" ]; then
    echo "Cloning user repositories from ${AVD_USER_REPOS}"
    while IFS= read -r line; do echo "  * cloning ${line}" && git clone ${line}; done < ${AVD_USER_REPOS}
fi

# Execute a user defined script to provision container with ${AVD_USER_SCRIPT}
if [ -f "${AVD_USER_SCRIPT}" ]; then
    echo "Runnin user script ${AVD_USER_SCRIPT}"
    chmod +x "${AVD_USER_SCRIPT}"
    sh -c "${AVD_USER_SCRIPT}"
fi

# Support for custom extension in mounted volume
# Use local path to file
if [ -f "${HOME}/${AVD_USER_EXTENSIONS_FILE}" ]; then
    echo "Installing custom extension from ${AVD_USER_EXTENSIONS_FILE}"
    while IFS= read -r line; do code-server --install-extension $line; done < ${AVD_USER_EXTENSIONS_FILE}
fi

if [ -n "${AVD_PASSWORD}" ]; then
    sh -c "PASSWORD=${AVD_PASSWORD} code-server --bind-addr 0.0.0.0:8080 --auth=password"
else
    sh -c "code-server --bind-addr 0.0.0.0:8080 --auth=none"
fi