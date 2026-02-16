#!/bin/bash
set -e

ROOT_PASSWORD=""
AUTHORIZED_KEYS=""
AUTHORIZED_KEYS_FILE="/run/secrets/ssh/authorized_keys"
SSHD_CONFIG="/etc/ssh/sshd_config"
USERNAME="bastion"

echo "Setting root password..."

if [ -f "$ROOT_PASSWORD" ]; then
    echo "root:$ROOT_PASSWORD" | chpasswd
fi


echo "Configuring non-root user..."

# Create the bastion user if not exists
if ! id -u $USERNAME >/dev/null 2>&1; then
    useradd -m -s /bin/bash $USERNAME
fi

# Setup SSH directory for the bastion user
mkdir -p /home/$USERNAME/.ssh
chmod 700 /home/$USERNAME/.ssh
chown $USERNAME:$USERNAME /home/$USERNAME/.ssh

# Install authorized keys
if [ -f "$AUTHORIZED_KEYS_FILE" ]; then
    echo "Installing SSH authorized keys for $USERNAME..."
    cp "$AUTHORIZED_KEYS_FILE" /home/$USERNAME/.ssh/authorized_keys
    chmod 600 /home/$USERNAME/.ssh/authorized_keys
    chown $USERNAME:$USERNAME /home/$USERNAME/.ssh/authorized_keys
else
    echo "WARNING: No authorized_keys found for bastion user!"
fi


echo "Hardening SSH configuration..."

# Backup default config
cp $SSHD_CONFIG ${SSHD_CONFIG}.bak

# Rebuild hardened sshd_config
cat <<EOF > $SSHD_CONFIG
# =========================================
# Hardened SSHD for Bastion Container
# =========================================

# Authentication
PasswordAuthentication no
ChallengeResponseAuthentication no
UsePAM no
PermitEmptyPasswords no
PubkeyAuthentication yes

# Root login is disabled
PermitRootLogin no

# Only allow our bastion user
AllowUsers $USERNAME

# Disable unused features
X11Forwarding no
AllowAgentForwarding no

# Allow TCP forwarding (because it's a bastion)
AllowTcpForwarding yes

# Session keepalive
ClientAliveInterval 300
ClientAliveCountMax 2

# Logging
LogLevel VERBOSE
EOF

echo "Starting SSH daemon..."
exec /usr/sbin/sshd -D
