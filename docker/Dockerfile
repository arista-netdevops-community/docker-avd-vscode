FROM avdteam/base:3.6


RUN apt update && \
    apt install -y nginx certbot python-certbot-nginx

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

EXPOSE 8080
ENTRYPOINT [ "/bin/entrypoint.sh" ]