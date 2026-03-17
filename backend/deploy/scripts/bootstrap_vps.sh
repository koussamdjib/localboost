#!/usr/bin/env bash
set -euo pipefail

# Run as root on a fresh Ubuntu VPS.

apt update
apt -y upgrade
apt -y install \
  git \
  nginx \
  postgresql \
  postgresql-contrib \
  python3 \
  python3-venv \
  python3-pip \
  certbot \
  python3-certbot-nginx \
  ufw \
  fail2ban

if ! id -u localboost >/dev/null 2>&1; then
  adduser --system --group --home /srv/localboost --shell /bin/bash localboost
fi

mkdir -p /srv/localboost
mkdir -p /etc/localboost
chown -R localboost:localboost /srv/localboost
chmod 750 /etc/localboost

# Firewall baseline
ufw allow OpenSSH
ufw allow 'Nginx Full'
ufw --force enable

echo "Bootstrap complete. Next: PostgreSQL setup, app deploy, systemd, nginx, certbot."
