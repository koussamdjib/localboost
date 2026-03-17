#!/usr/bin/env bash
set -eu

if [[ "${EUID}" -ne 0 ]]; then
  echo "Run as root."
  exit 1
fi

TS="$(date +%F-%H%M%S)"

if ! command -v psql >/dev/null 2>&1; then
  echo "PostgreSQL client not found."
  exit 1
fi

DB_PASS="$(LC_ALL=C tr -dc 'A-Za-z0-9' </dev/urandom | head -c 32)"
if [[ ${#DB_PASS} -lt 20 ]]; then
  DB_PASS="$(date +%s%N)LocalBoost42"
fi

# Drop legacy NearDeal objects if present.
sudo -u postgres psql -v ON_ERROR_STOP=1 -c "SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname='neardeal_pg' AND pid <> pg_backend_pid();" || true
sudo -u postgres psql -v ON_ERROR_STOP=1 -c "DROP DATABASE IF EXISTS neardeal_pg;"
sudo -u postgres psql -v ON_ERROR_STOP=1 -c "DROP ROLE IF EXISTS neardeal_pg_app;"

# Recreate clean LocalBoost DB and role.
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

sudo -u postgres psql -c "\\l+"
sudo -u postgres psql -c "\\du+"

echo "PostgreSQL reset complete. Credentials saved at: ${CRED_FILE}"
