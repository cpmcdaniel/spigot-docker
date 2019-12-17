FROM azul/zulu-openjdk-alpine:8

LABEL maintainer="cpmcdaniel@gmail.com"

COPY spigot /usr/local/bin

RUN apk update && apk upgrade && \
    apk add curl git tmux bash && \
    apk add gosu --update-cache --repository http://dl-3.alpinelinux.org/alpine/edge/testing/ --allow-untrusted
    
RUN addgroup -g 1000 minecraft && \
    adduser -G minecraft -u 1000 -S minecraft && \
    mkdir -p /var/lib/minecraft /opt/minecraft && \
    chown minecraft:minecraft /var/lib/minecraft /opt/minecraft && \
    echo "set -g status off" > /root/.tmux.conf && \
    chmod +x /usr/local/bin/spigot

VOLUME ["/opt/minecraft", "/var/lib/minecraft"]

EXPOSE 25565

ENTRYPOINT ["/usr/local/bin/spigot"]

CMD ["run"]