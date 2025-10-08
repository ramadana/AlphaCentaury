# =========================================================
# Bastion Host Image for skies-nrt
# =========================================================
FROM alpine:3.22.2

LABEL maintainer="Pramandha Arthadana <rama@rmdn.dev>" \
      description="Lightweight Bastion Host with essential DB tools" \
      version="1.0"

# ---------------------------------------------------------
# Install base tools: OpenSSH, PostgreSQL client, Redis CLI
# ---------------------------------------------------------
RUN apk add --no-cache \
    openssh-server \
    postgresql-client \
    redis \
    curl \
    tar \
    ca-certificates

# ---------------------------------------------------------
# Try installing mongosh from Alpine repo if available
# ---------------------------------------------------------
RUN if ! apk add --no-cache mongosh; then \
      echo "mongosh not available in Alpine repo. Installing manually..." && \
      curl -L -o /tmp/mongosh.tgz https://downloads.mongodb.com/compass/mongosh-2.5.9-linux-x64.tgz && \
      mkdir -p /opt/mongosh && \
      tar -xzf /tmp/mongosh.tgz -C /opt/mongosh --strip-components=1 && \
      ln -sf /opt/mongosh/bin/mongosh /usr/local/bin/mongosh && \
      rm -f /tmp/mongosh.tgz; \
    fi

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

