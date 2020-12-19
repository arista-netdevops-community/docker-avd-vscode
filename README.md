![](https://img.shields.io/badge/Arista-CVP%20Automation-blue)  ![](https://img.shields.io/badge/Arista-EOS%20Automation-blue) ![GitHub](https://img.shields.io/github/license/arista-netdevops-community/docker-avd-vscode) ![Docker Pulls](https://img.shields.io/docker/pulls/avdteam/vscode) ![Docker Image Size (tag)](https://img.shields.io/docker/image-size/avdteam/vscode/latest) ![Docker Image Version (tag latest semver)](https://img.shields.io/docker/v/avdteam/vscode/latest)
# VScode for AVD

## About

This repository provides a Docker image running [cdr/code-server](https://github.com/cdr/code-server/) preconfigued with [Arista Validated Design](https://www.avd.sh) environment.

__Docker image__: [avdteam/vscode](https://hub.docker.com/repository/docker/avdteam/vscode)

<p align="center"><img src="medias/AVD%20-%20Docker%20Logo%20transparent%20bg.png" alt="Arista AVD Docker Image" width="400"/></p>

## Getting started

```bash
# Run avdteam/vscode container
$ docker run --rm -d -v /var/run/docker.sock:/var/run/docker.sock -p 8080:8080 avdteam/vscode:latest

# Connect to your browser
$ open http://127.0.0.1:8080
```

> As it is for development and local use only, there is no password protection ! Never expose container to untrust or Internet.

## Container options

### Generic settings

- __`AVD_MODE`__: If set to `demo`, container will install AVD content to test it from `get.avd.sh`.
  - Supported mode: `['demo', 'toi']`
- __`AVD_PASSWORD`__: Allow user to set a password to use for VScode authentcation. If not set, access is not protected by any password.
- __`AVD_GIT_USER`__: Username to configure in `.gitconfig` file.
  - Can be set with `AVD_GIT_USER=$(git config --get user.name)`
- __`AVD_GIT_EMAIL`__: Email to configure in `.gitconfig` file.
  - Can be set with `AVD_GIT_EMAIL=$(git config --get user.email)`
- __`AVD_USER_EXTENSIONS_FILE`__: Allow user to installed additional VScode extensions
- __`AVD_USER_REPOS`__: Path to a text file in your container with a list of repository to clone (1 repository per line)
- __`AVD_USER_SCRIPT`__: Path to a shell script to execute during entrypoint execution.

### User settings

These settings must be used to mount and edit file from your physical host.

- __`AVD_UID`__: set uid for avd user in container.
- __`AVD_GID`__: set gid for avd user in container.

## Examples

### Use container to run demo content

```bash
docker run --rm -it -d \
    -e AVD_MODE=demo \
    -e AVD_GIT_USER=titom73 \
    -e AVD_GIT_EMAIL=tom@inetsix.net \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -p 8080:8080 \
    avdteam/vscode:latest
```

### Use container to work on your local version

```bash
docker run --rm -it -d \
    -e AVD_GIT_USER=titom73 \
    -e AVD_GIT_EMAIL=tom@inetsix.net \
    -v ${PWD}/your-local-work:/home/avd/arista-ansible \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -p 8080:8080 \
    avdteam/vscode:latest
```

### Use container with your custom extensions list

```bash
docker run --rm -it -d \
    -e AVD_USER_EXTENSIONS_FILE=my_settings/user-extensions.txt \
    -e AVD_GIT_USER=titom73 \
    -e AVD_GIT_EMAIL=tom@inetsix.net \
    -v ${PATH_TO_FOLDER_WITH_EXT_FILE}/tests:/home/avd/my_settings \
    -v ${PWD}/your-local-work:/home/avd/arista-ansible \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -p 8080:8080 \
    avdteam/vscode:latest
```

## Deployment Scenario

### Docker Compose

Easy to manage TOI and ATD with docker-compose command

- [Docker Compose stack example](./docker-compose.yml)

```bash
# Start single node stack
$ docker-compose up -d
Creating network "avd-vscode_default" with the default driver
Creating avd-vscode_avd-coder_1 ... done

# get dynamic port mapping
$ docker-compose ps
         Name                 Command         State            Ports
-----------------------------------------------------------------------------
avd-vscode_avd-coder_1   /bin/entrypoint.sh   Up      0.0.0.0:55000->8080/tcp

# Scale up environment
$ docker-compose --scale avd-coder=3
Creating avd-vscode_avd-coder_2 ... done
Creating avd-vscode_avd-coder_3 ... done

$ docker-compose ps
         Name                 Command         State            Ports
-----------------------------------------------------------------------------
avd-vscode_avd-coder_1   /bin/entrypoint.sh   Up      0.0.0.0:55000->8080/tcp
avd-vscode_avd-coder_2   /bin/entrypoint.sh   Up      0.0.0.0:55002->8080/tcp
avd-vscode_avd-coder_3   /bin/entrypoint.sh   Up      0.0.0.0:55001->8080/tcp
```

### Kubernetes deployment

- [Kubernetes deployment manifest](./k8s-deployment.yml)

```yaml
$ kubectl apply -f k8s-deployment.yml
deployment.apps/avd-coder-deployment created
service/avd-coder-service created

$ kubectl get service
NAME                TYPE       CLUSTER-IP       EXTERNAL-IP   PORT(S)          AGE
avd-coder-service   NodePort   10.152.183.196   <none>        8080:31081/TCP   5s
```

### Alias for shell rc file

```bash
# AVD VScode image name
export AVD_VSCODE_IMAGE=avdteam/vscode

# Version of AVD VScode image to use
export AVD_VSCODE_VERSION=latest

# Vscode container command line to start
base_avd_vsc() {
        container_id=$(docker run -P -it --rm -d \
          -e AVD_GIT_USER="$(git config --get user.name)" \
          -e AVD_GIT_EMAIL="$(git config --get user.email)" \
          -v /var/run/docker.sock:/var/run/docker.sock \
          -v ${PWD}/:/home/avd/local_projects \
          ${AVD_VSCODE_IMAGE}:${AVD_VSCODE_VERSION})
        echo "Container ${container_id} has been created ..."
        export mapped_port=$(docker inspect --format="{{(index (index .NetworkSettings.Ports \"8080/tcp\") 0).HostPort}}" ${container_id})
        echo "-> Open http://127.0.0.1:${mapped_port}/?folder=/home/avd"
}

# Stop all VScode isntances
avd-vsc-stop() {
  docker ps -a | grep -e "${AVD_VSCODE_IMAGE}" | gawk '{print $1}' | xargs docker stop
}

# Alias to start a new instance from where you are in shell
alias avd-vsc='base_avd_vsc'

# Update image from docker-hub
alias avd-vsc-update='docker pull ${AVD_VSCODE_IMAGE}:${AVD_VSCODE_VERSION}'
```

## License

Project is published under [Apache 2.0 License](./LICENSE)
