#!/usr/bin/env bash
set -euo pipefail

if [[ "${EUID}" -ne 0 ]]; then
  echo "Run as root."
  exit 1
fi

TS="$(date +%F-%H%M%S)"
LOG="/tmp/localboost-clean-${TS}.log"
exec > >(tee -a "$LOG") 2>&1

echo "===== LocalBoost VPS Clean Start: ${TS} ====="

echo ""
echo "PHASE 1 - SERVER INSPECTION"
uname -a || true
cat /etc/os-release || true
lsb_release -a 2>/dev/null || true

df -hT || true
free -h || true
du -xh --max-depth=1 /srv /var/www /opt 2>/dev/null | sort -h || true

systemctl --type=service --state=running --no-pager || true

nginx -v 2>&1 || true
ls -lah /etc/nginx || true
ls -lah /etc/nginx/sites-available || true
ls -lah /etc/nginx/sites-enabled || true
nginx -T 2>/dev/null | sed -n '1,220p' || true

systemctl list-unit-files --type=service --no-pager | grep -Ei 'gunicorn|uvicorn|daphne|celery|django|localboost|nginx|postgres|docker' || true

command -v python3 || true
python3 --version || true
pip3 --version 2>/dev/null || true
find /srv /var/www /opt -maxdepth 5 -type d \( -name ".venv" -o -name "venv" -o -name "env" \) -print 2>/dev/null || true

if command -v psql >/dev/null 2>&1; then
  sudo -u postgres psql -c "\\l+" || true
  sudo -u postgres psql -c "\\du+" || true
fi

ls -lah /srv || true
ls -lah /var/www || true
ls -lah /opt || true

echo ""
echo "PHASE 2 - STOP OLD SERVICES"
systemctl stop nginx || true

mapfile -t OLD_APP_SERVICES < <(systemctl list-unit-files --type=service --no-legend | awk '{print $1}' | grep -Ei 'gunicorn|uvicorn|daphne|celery|django|localboost' || true)
printf '%s\n' "${OLD_APP_SERVICES[@]:-<none>}"
for svc in "${OLD_APP_SERVICES[@]}"; do
  [[ -n "$svc" ]] || continue
  systemctl stop "$svc" || true
  systemctl disable "$svc" || true
done

if command -v docker >/dev/null 2>&1; then
  docker ps --format 'table {{.ID}}\t{{.Names}}\t{{.Image}}' || true
  IDS="$(docker ps -q || true)"
  if [[ -n "$IDS" ]]; then
    docker stop $IDS || true
  fi
fi

echo ""
echo "PHASE 3 - CLEAN OLD PROJECT FILES"
find /srv -mindepth 1 -maxdepth 1 -print 2>/dev/null || true
find /var/www -mindepth 1 -maxdepth 1 -print 2>/dev/null || true
find /opt -mindepth 1 -maxdepth 2 -type d -name "*localboost*" -print 2>/dev/null || true

rm -rf /srv/* || true
rm -rf /var/www/* || true
find /opt -mindepth 1 -maxdepth 1 -type d -name "*localboost*" -exec rm -rf {} + || true

echo ""
echo "PHASE 4 - CLEAN NGINX"
NG_BAK="/root/nginx-backup-${TS}"
mkdir -p "$NG_BAK"
cp -a /etc/nginx/sites-available "$NG_BAK/" 2>/dev/null || true
cp -a /etc/nginx/sites-enabled "$NG_BAK/" 2>/dev/null || true

rm -f /etc/nginx/sites-enabled/* || true
find /etc/nginx/sites-available -mindepth 1 -maxdepth 1 -type f -delete || true

cat >/etc/nginx/sites-available/00-clean-placeholder.conf <<'EOF'
server {
    listen 80 default_server;
    listen [::]:80 default_server;
    server_name _;
    return 444;
}
EOF
ln -sf /etc/nginx/sites-available/00-clean-placeholder.conf /etc/nginx/sites-enabled/00-clean-placeholder.conf

nginx -t
systemctl restart nginx

echo ""
echo "PHASE 5 - CLEAN PYTHON ENVIRONMENTS"
find /srv /var/www /opt -maxdepth 6 -type d \( -name ".venv" -o -name "venv" -o -name "env" \) -print 2>/dev/null || true
find /srv /var/www /opt -maxdepth 6 -type d \( -name ".venv" -o -name "venv" -o -name "env" \) -exec rm -rf {} + 2>/dev/null || true

python3 -m pip cache purge 2>/dev/null || true
rm -rf /root/.cache/pip /home/ubuntu/.cache/pip || true

echo ""
echo "PHASE 6 - CLEAN POSTGRESQL"
if command -v psql >/dev/null 2>&1; then
  sudo -u postgres psql -c "\\l+" || true
  sudo -u postgres psql -c "\\du+" || true

  DB_PASS="$(LC_ALL=C tr -dc 'A-Za-z0-9' </dev/urandom | head -c 32)"

  sudo -u postgres psql -v ON_ERROR_STOP=1 -c "SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname='localboost' AND pid <> pg_backend_pid();" || true
  sudo -u postgres psql -v ON_ERROR_STOP=1 -c "DROP DATABASE IF EXISTS localboost;"
  sudo -u postgres psql -v ON_ERROR_STOP=1 -c "DROP ROLE IF EXISTS localboost;"
  sudo -u postgres psql -v ON_ERROR_STOP=1 -c "CREATE ROLE localboost LOGIN PASSWORD '${DB_PASS}';"
  sudo -u postgres psql -v ON_ERROR_STOP=1 -c "CREATE DATABASE localboost OWNER localboost;"

  CRED_FILE="/root/localboost-db-credentials-${TS}.txt"
  {
    echo "DB_NAME=localboost"
    echo "DB_USER=localboost"
    echo "DB_PASSWORD=${DB_PASS}"
  } >"${CRED_FILE}"
  chmod 600 "${CRED_FILE}"

  echo "Fresh localboost DB/user created. Credentials saved at: ${CRED_FILE}"
fi

echo ""
echo "PHASE 7 - VERIFY CLEAN STATE"
ls -lah /etc/nginx/sites-available || true
ls -lah /etc/nginx/sites-enabled || true
nginx -t || true
systemctl status nginx --no-pager || true

systemctl --type=service --state=running --no-pager | grep -Ei 'gunicorn|uvicorn|daphne|celery|django|localboost' || echo "No app services running."
pgrep -af 'gunicorn|uvicorn|daphne|celery' || echo "No gunicorn/uvicorn/daphne/celery process."

if command -v docker >/dev/null 2>&1; then
  docker ps || true
fi

if command -v psql >/dev/null 2>&1; then
  sudo -u postgres psql -c "\\l+" || true
  sudo -u postgres psql -c "\\du+" || true
fi

find /srv -mindepth 1 -maxdepth 2 -print 2>/dev/null || true
find /var/www -mindepth 1 -maxdepth 2 -print 2>/dev/null || true
find /opt -mindepth 1 -maxdepth 2 -name "*localboost*" -print 2>/dev/null || true

df -hT || true

echo "===== LocalBoost VPS Clean Completed ====="
echo "Log file: ${LOG}"
