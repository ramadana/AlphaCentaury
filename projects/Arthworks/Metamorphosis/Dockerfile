# ==================================================================
# Metamorphosis: Lightweight Bastion Host
# ==================================================================
FROM alpine:latest

LABEL maintainer="Pramandha Arthadana <rama@rmdn.dev>" \
      description="Lightweight Bastion Host" \
      version="1.0"

RUN echo "Upgrading current packages ..." && \
    apk update && apk upgrade

RUN echo "Installing Essential Tools ..." && \
    apk add --no-cache \
    ca-certificates curl

RUN echo "Installing Other Essential Tools ..." && \
    apk add --no-cache \
    openssh-server openssh-client \
    nano \ 
    7zip \
    gzip \
    tar

EXPOSE 22

CMD ["/usr/sbin/sshd", "-D"]