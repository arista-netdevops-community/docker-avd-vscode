FROM avdteam/base:3.6

LABEL maintainer="Arista Ansible Team <ansible@arista.com>"
LABEL com.example.version="0.0.2"
LABEL vendor1="Arista"
LABEL com.example.release-date="2020-12-16"
LABEL com.example.version.is-production="False"

RUN mkdir -p /home/avd/.local/share/code-server && \
    mkdir -p /home/avd/.local/share/code-server/User && \
    chown avd:avd -R /home/avd/.local/share/ && \
    curl -fsSL https://code-server.dev/install.sh | sh

COPY entrypoint.sh /bin/entrypoint.sh
RUN chmod +x /bin/entrypoint.sh

USER avd
WORKDIR /home/avd

COPY vs-extensions.txt /home/avd/extensions.txt
RUN while IFS= read -r line; do code-server --install-extension $line; done < extensions.txt && \
    rm /home/avd/extensions.txt

COPY settings.json /home/avd/.local/share/code-server/User/settings.json
COPY gitconfig /home/avd/.gitconfig

RUN sudo chown avd:avd -R /home/avd/.local/share && \
    sudo chmod 755 -R /home/avd/.local/share/code-server

EXPOSE 8080
ENTRYPOINT [ "/bin/entrypoint.sh" ]