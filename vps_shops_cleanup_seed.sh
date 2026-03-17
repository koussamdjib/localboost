#!/usr/bin/env bash
set -euo pipefail

SSH_PORT="${SSH_PORT:-2222}"
SSH_TARGET="${SSH_TARGET:-ubuntu@sirius-djibouti.com}"
REMOTE_APP_DIR="${REMOTE_APP_DIR:-/srv/localboost/backend}"
REMOTE_PYTHON="${REMOTE_PYTHON:-/srv/localboost/.venv/bin/python3}"
LOCAL_CLEANUP_SCRIPT="${LOCAL_CLEANUP_SCRIPT:-backend/deploy/scripts/cleanup_seed_shop_discovery_data.py}"
REMOTE_CLEANUP_SCRIPT="${REMOTE_CLEANUP_SCRIPT:-/tmp/cleanup_seed_shop_discovery_data.py}"
VERIFY_STRICT="${VERIFY_STRICT:-0}"

echo "[1/3] Upload cleanup script"
scp -q -o BatchMode=yes -o ConnectTimeout=15 -P "$SSH_PORT" \
  "$LOCAL_CLEANUP_SCRIPT" \
  "$SSH_TARGET:$REMOTE_CLEANUP_SCRIPT"

echo "[2/3] Execute cleanup script on VPS"
ssh -o BatchMode=yes -o ConnectTimeout=15 -p "$SSH_PORT" "$SSH_TARGET" \
  "sudo -n -u localboost $REMOTE_PYTHON $REMOTE_APP_DIR/manage.py shell < $REMOTE_CLEANUP_SCRIPT"

echo "[3/3] Verify shops endpoint state"
VERIFY_CMD="ALLOW_EMPTY_RESULTS=1 EXPECTED_SLUG='' bash vps_shops_live_verify_only.sh"
if [[ "$VERIFY_STRICT" == "1" ]]; then
  bash -lc "$VERIFY_CMD"
else
  bash -lc "$VERIFY_CMD" || true
fi

echo "DONE"
