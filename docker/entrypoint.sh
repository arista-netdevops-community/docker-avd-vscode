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

# Configure local docker socket permissions
if [ -S ${DOCKER_SOCKET} ]; then
    sudo chmod 666 /var/run/docker.sock &>/dev/null
fi

export PATH=$PATH:/home/avd/.local/bin
export LC_ALL=C.UTF-8

cd /home/avd/

# Start clone process if running in DEMO/ATD mode
if [  "${AVD_MODE}" == "demo" ]; then
  echo "Running in demo/ATD mode"
  echo "  * Getting repositories from Gthub"
  curl https://get.avd.sh/ | sh
else
    # Support for custom extension in mounted volume
    # Use local path to file
    echo "AVD_USER_EXTENSIONS_FILE is set to ${AVD_USER_EXTENSIONS_FILE}"
    if [ -f "${HOME}/${AVD_USER_EXTENSIONS_FILE}" ]; then
        echo "Installing custom extension from ${AVD_USER_EXTENSIONS_FILE}"
        while IFS= read -r line; do code-server --install-extension $line; done < ${HOME}/${AVD_USER_EXTENSIONS_FILE}
    fi
fi

sh -c "code-server --bind-addr 0.0.0.0:8080 --auth=none"