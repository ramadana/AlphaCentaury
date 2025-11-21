# ==================================================================
# Stratios Image: Lightweight Bastion Host with essential DB tools
# ==================================================================
FROM debian:13-slim

LABEL maintainer="Pramandha Arthadana <rama@rmdn.dev>" \
      description="Lightweight Bastion Host with essential DB tools" \
      version="1.0"

RUN echo "Upgrading current packages ..." && \
    apt update && apt upgrade -y

RUN echo "Installing Mongo Shell (mongosh) ..." && \
      curl -L -o /tmp/mongosh.tgz https://downloads.mongodb.com/compass/mongosh-2.5.9-linux-x64.tgz && \
      mkdir -p /opt/mongosh && \
      tar -xzf /tmp/mongosh.tgz -C /opt/mongosh --strip-components=1 && \
      chmod +x /opt/mongosh/bin/mongosh && \
      ln -sf /opt/mongosh/bin/mongosh /usr/local/bin/mongosh && \
      rm -f /tmp/mongosh.tgz;

RUN echo "Installing PostgreSQL Client (postgresql-client) ..." && \
    apt install -y \
    ca-certificates \
    postgresql-client

RUN echo "Installing Other Essential Tools ..." && \
    apt install -y \
    openssh-server \
    curl \
    nano \ 
    tar 

# ---------------------------------------------------------
# SSH server configuration
# ---------------------------------------------------------
RUN mkdir -p /run/sshd && \
    ssh-keygen -A && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    echo "root:toor" | chpasswd && \
    echo "Password authentication enabled for internal use only."

# ---------------------------------------------------------
# Expose SSH port
# ---------------------------------------------------------
EXPOSE 22

# ---------------------------------------------------------
# Set default command
# ---------------------------------------------------------
CMD ["/usr/sbin/sshd", "-D"]

