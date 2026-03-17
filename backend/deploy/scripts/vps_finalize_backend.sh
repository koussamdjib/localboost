#!/usr/bin/env bash
set -euo pipefail

DOMAIN="sirius-djibouti.com"
APP_ROOT="/srv/localboost"
APP_DIR="$APP_ROOT/backend"
VENV_DIR="$APP_ROOT/.venv"
ENV_DIR="/etc/localboost"
ENV_FILE="$ENV_DIR/localboost-backend.env"
SERVICE_FILE="/etc/systemd/system/localboost-backend.service"
NGINX_SITE="/etc/nginx/sites-available/localboost-backend"

log() {
  echo
  echo "[INFO] $*"
}

require_path() {
  local p="$1"
  if [[ ! -e "$p" ]]; then
    echo "[ERROR] Missing required path: $p"
    exit 1
  fi
}

log "Validating required app files"
require_path "$APP_DIR/manage.py"
require_path "$APP_DIR/requirements.txt"

log "Ensuring localboost user and base directories"
id -u localboost >/dev/null 2>&1 || useradd --system --create-home --shell /bin/bash localboost
mkdir -p "$APP_ROOT" "$ENV_DIR"

log "Fixing ownership and base permissions"
chown -R localboost:localboost "$APP_ROOT"
chmod 755 "$APP_ROOT" "$APP_DIR"

log "Preparing Python virtual environment"
if [[ ! -d "$VENV_DIR" ]]; then
  python3 -m venv "$VENV_DIR"
fi
chown -R localboost:localboost "$VENV_DIR"

sudo -u localboost -H "$VENV_DIR/bin/pip" install --upgrade pip
sudo -u localboost -H "$VENV_DIR/bin/pip" install -r "$APP_DIR/requirements.txt"

log "Creating or updating PostgreSQL role/database"
DB_USER="localboost"
DB_NAME="localboost"
DB_PASS="$(openssl rand -base64 24)"

if sudo -u postgres psql -tAc "SELECT 1 FROM pg_roles WHERE rolname='${DB_USER}'" | grep -q 1; then
  sudo -u postgres psql -c "ALTER ROLE ${DB_USER} WITH LOGIN PASSWORD '${DB_PASS}';"
else
  sudo -u postgres psql -c "CREATE ROLE ${DB_USER} WITH LOGIN PASSWORD '${DB_PASS}';"
fi

if sudo -u postgres psql -tAc "SELECT 1 FROM pg_database WHERE datname='${DB_NAME}'" | grep -q 1; then
  sudo -u postgres psql -c "ALTER DATABASE ${DB_NAME} OWNER TO ${DB_USER};"
else
  sudo -u postgres psql -c "CREATE DATABASE ${DB_NAME} OWNER ${DB_USER};"
fi

sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE ${DB_NAME} TO ${DB_USER};"

log "Creating production env file"
DJANGO_SECRET="$(openssl rand -hex 32)"
cat > "$ENV_FILE" <<EOF
DJANGO_SETTINGS_MODULE=config.settings.production
DJANGO_SECRET_KEY=${DJANGO_SECRET}
DJANGO_DEBUG=false

DJANGO_ALLOWED_HOSTS=${DOMAIN}
DJANGO_CSRF_TRUSTED_ORIGINS=https://${DOMAIN}
DJANGO_CORS_ALLOWED_ORIGINS=https://${DOMAIN}

POSTGRES_DB=${DB_NAME}
POSTGRES_USER=${DB_USER}
POSTGRES_PASSWORD=${DB_PASS}
POSTGRES_HOST=127.0.0.1
POSTGRES_PORT=5432
POSTGRES_SSLMODE=prefer

API_PAGE_SIZE=20
JWT_ACCESS_MINUTES=30
JWT_REFRESH_DAYS=30

DJANGO_SECURE_SSL_REDIRECT=true
DJANGO_SECURE_HSTS_SECONDS=31536000
EOF

chown root:localboost "$ENV_FILE"
chmod 640 "$ENV_FILE"

log "Running Django migrations and collectstatic"
sudo -u localboost -H bash -lc "set -a; source '$ENV_FILE'; set +a; cd '$APP_DIR'; '$VENV_DIR/bin/python' manage.py migrate --noinput"
sudo -u localboost -H bash -lc "set -a; source '$ENV_FILE'; set +a; cd '$APP_DIR'; '$VENV_DIR/bin/python' manage.py collectstatic --noinput"
sudo -u localboost -H bash -lc "set -a; source '$ENV_FILE'; set +a; cd '$APP_DIR'; '$VENV_DIR/bin/python' manage.py check --deploy"

log "Adjusting static/media permissions for nginx"
mkdir -p "$APP_DIR/staticfiles" "$APP_DIR/media"
chgrp -R www-data "$APP_DIR/staticfiles" "$APP_DIR/media"
find "$APP_DIR/staticfiles" -type d -exec chmod 755 {} +
find "$APP_DIR/staticfiles" -type f -exec chmod 644 {} +
find "$APP_DIR/media" -type d -exec chmod 755 {} +
find "$APP_DIR/media" -type f -exec chmod 644 {} +

log "Installing systemd service"
cat > "$SERVICE_FILE" <<'EOF'
[Unit]
Description=LocalBoost Django Backend (Gunicorn)
After=network.target

[Service]
Type=simple
User=localboost
Group=www-data
WorkingDirectory=/srv/localboost/backend
EnvironmentFile=/etc/localboost/localboost-backend.env
ExecStart=/srv/localboost/.venv/bin/gunicorn \
  --workers 3 \
  --bind 127.0.0.1:8000 \
  --access-logfile - \
  --error-logfile - \
  config.wsgi:application
Restart=always
RestartSec=5
TimeoutStopSec=30
KillSignal=SIGTERM

[Install]
WantedBy=multi-user.target
EOF

log "Installing nginx site"
cat > "$NGINX_SITE" <<'EOF'
server {
    listen 80;
    listen [::]:80;
    server_name sirius-djibouti.com;

    client_max_body_size 20M;

    location /static/ {
        alias /srv/localboost/backend/staticfiles/;
        access_log off;
        expires 30d;
        add_header Cache-Control "public, max-age=2592000";
    }

    location /media/ {
        alias /srv/localboost/backend/media/;
        access_log off;
        expires 7d;
        add_header Cache-Control "public, max-age=604800";
    }

    location / {
        proxy_pass http://127.0.0.1:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_redirect off;
    }
}
EOF

ln -sfn "$NGINX_SITE" /etc/nginx/sites-enabled/localboost-backend
rm -f /etc/nginx/sites-enabled/default

log "Reloading systemd and nginx, starting backend service"
systemctl daemon-reload
systemctl enable --now localboost-backend
systemctl restart localboost-backend
nginx -t
systemctl reload nginx

log "Checking local gunicorn health"
ss -ltnp | grep ':8000'
curl -fsS "http://127.0.0.1:8000/api/v1/health/" | sed -n '1,2p'

log "Ensuring certbot is installed"
if ! command -v certbot >/dev/null 2>&1; then
  apt-get update
  apt-get install -y certbot python3-certbot-nginx
fi

log "Issuing or renewing Let's Encrypt certificate"
certbot --nginx --non-interactive --agree-tos --register-unsafely-without-email --redirect -d "$DOMAIN" --keep-until-expiring

log "Testing certbot renewal dry-run"
certbot renew --dry-run

log "Running production verification script"
chmod +x "$APP_DIR/deploy/scripts/verify_production.sh"
DOMAIN="$DOMAIN" GUNICORN_PORT=8000 "$APP_DIR/deploy/scripts/verify_production.sh"

log "Done. LocalBoost backend should now be live on https://$DOMAIN"
