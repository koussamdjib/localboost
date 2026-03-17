#!/usr/bin/env bash
set -euo pipefail

# Run as root or with sudo on VPS after code is present in /srv/localboost.

APP_ROOT="/srv/localboost"
BACKEND_DIR="$APP_ROOT/backend"
VENV_DIR="$APP_ROOT/.venv"
ENV_FILE="/etc/localboost/localboost-backend.env"

if [[ ! -f "$ENV_FILE" ]]; then
  echo "Missing $ENV_FILE"
  exit 1
fi

if [[ ! -d "$VENV_DIR" ]]; then
  python3 -m venv "$VENV_DIR"
fi

"$VENV_DIR/bin/pip" install --upgrade pip
"$VENV_DIR/bin/pip" install -r "$BACKEND_DIR/requirements.txt"

set -a
source "$ENV_FILE"
set +a

cd "$BACKEND_DIR"
"$VENV_DIR/bin/python" manage.py migrate --noinput
"$VENV_DIR/bin/python" manage.py collectstatic --noinput
"$VENV_DIR/bin/python" manage.py check --deploy

systemctl daemon-reload
systemctl enable --now localboost-backend
systemctl restart localboost-backend
nginx -t
systemctl reload nginx

echo "Deployment complete."
