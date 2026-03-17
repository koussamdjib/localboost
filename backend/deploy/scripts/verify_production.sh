#!/usr/bin/env bash
set -uo pipefail

# LocalBoost backend production verification.
# Runs health diagnostics for service, nginx, gunicorn, PostgreSQL,
# migrations, static/media serving, HTTPS, and API reachability.

DOMAIN="${DOMAIN:-sirius-djibouti.com}"
SERVICE="${SERVICE:-localboost-backend}"
APP_DIR="${APP_DIR:-/srv/localboost/backend}"
ENV_FILE="${ENV_FILE:-/etc/localboost/localboost-backend.env}"
VENV_PYTHON="${VENV_PYTHON:-/srv/localboost/.venv/bin/python}"
GUNICORN_PORT="${GUNICORN_PORT:-8000}"
HEALTH_PATH="${HEALTH_PATH:-/api/v1/health/}"
STATIC_PROBE="${STATIC_PROBE:-/static/admin/css/base.css}"

PASS_COUNT=0
FAIL_COUNT=0

as_root() {
    if [[ "$(id -u)" -eq 0 ]]; then
        "$@"
    else
        sudo "$@"
    fi
}

load_env_file() {
    if [[ ! -f "$ENV_FILE" ]]; then
        echo "Missing env file: $ENV_FILE"
        return 1
    fi

    set -a
    # shellcheck disable=SC1090
    source "$ENV_FILE"
    set +a
}

run_check() {
    local title="$1"
    local fn_name="$2"

    echo
    echo "=== $title ==="

    if "$fn_name"; then
        echo "RESULT: PASS"
        PASS_COUNT=$((PASS_COUNT + 1))
    else
        echo "RESULT: FAIL"
        FAIL_COUNT=$((FAIL_COUNT + 1))
    fi
}

check_systemd_service() {
    echo "$ systemctl is-active --quiet $SERVICE"
    as_root systemctl is-active --quiet "$SERVICE" || return 1

    echo "$ systemctl status $SERVICE --no-pager -l"
    as_root systemctl status "$SERVICE" --no-pager -l || return 1
}

check_nginx_config() {
    echo "$ nginx -t"
    as_root nginx -t || return 1

    echo "$ systemctl is-active --quiet nginx"
    as_root systemctl is-active --quiet nginx || return 1

    echo "$ systemctl status nginx --no-pager -l"
    as_root systemctl status nginx --no-pager -l || return 1
}

check_gunicorn_response() {
    echo "$ ss -ltnp | grep :$GUNICORN_PORT"
    as_root ss -ltnp | grep ":$GUNICORN_PORT" || return 1

    echo "$ curl -fsS http://127.0.0.1:$GUNICORN_PORT$HEALTH_PATH"
    curl -fsS "http://127.0.0.1:$GUNICORN_PORT$HEALTH_PATH" || return 1
    echo
}

check_postgresql_connection() {
    load_env_file || return 1

    echo "$ $VENV_PYTHON manage.py shell (DB ensure_connection)"
    (
        cd "$APP_DIR" || exit 1
        "$VENV_PYTHON" manage.py shell -c "from django.db import connection; connection.ensure_connection(); print('DB OK:', connection.settings_dict['NAME'])"
    ) || return 1

    echo "$ psql connectivity check"
    PGPASSWORD="${POSTGRES_PASSWORD:-}" \
        psql \
        -h "${POSTGRES_HOST:-127.0.0.1}" \
        -U "${POSTGRES_USER:-localboost_user}" \
        -d "${POSTGRES_DB:-localboost}" \
        -c "select now(), current_database(), current_user;" || return 1
}

check_migrations_applied() {
    load_env_file || return 1

    echo "$ $VENV_PYTHON manage.py migrate --check"
    (
        cd "$APP_DIR" || exit 1
        "$VENV_PYTHON" manage.py migrate --check
    ) || return 1
}

check_static_files_served() {
    local static_file="$APP_DIR/staticfiles/admin/css/base.css"

    echo "$ test -f $static_file"
    test -f "$static_file" || return 1

    echo "$ curl -fsSI https://$DOMAIN$STATIC_PROBE"
    curl -fsSI "https://$DOMAIN$STATIC_PROBE" || return 1
}

check_media_upload() {
    load_env_file || return 1

    local probe_path="health/upload-test-$(date +%s).txt"

    echo "$ create media probe via Django storage"
    (
        cd "$APP_DIR" || exit 1
        "$VENV_PYTHON" manage.py shell -c "from django.core.files.storage import default_storage; from django.core.files.base import ContentFile; path='$probe_path'; saved=default_storage.save(path, ContentFile(b'localboost-media-ok')); print(saved)"
    ) || return 1

    echo "$ curl -fsS https://$DOMAIN/media/$probe_path"
    curl -fsS "https://$DOMAIN/media/$probe_path" | grep -q "localboost-media-ok" || return 1

    echo "$ cleanup media probe"
    (
        cd "$APP_DIR" || exit 1
        "$VENV_PYTHON" manage.py shell -c "from django.core.files.storage import default_storage; default_storage.delete('$probe_path'); print('cleanup ok')"
    ) || return 1
}

check_https_active() {
    echo "$ curl -fsSI https://$DOMAIN"
    curl -fsSI "https://$DOMAIN" || return 1

    echo "$ openssl certificate dates"
    echo | openssl s_client -connect "$DOMAIN:443" -servername "$DOMAIN" 2>/dev/null | openssl x509 -noout -subject -issuer -dates || return 1
}

check_api_endpoint() {
    echo "$ curl -fsS https://$DOMAIN$HEALTH_PATH"
    curl -fsS "https://$DOMAIN$HEALTH_PATH" | grep -q '"status"' || return 1
}

check_certbot_renewal() {
    local lock_wait_seconds="${CERTBOT_LOCK_WAIT_SECONDS:-300}"
    local waited=0

    echo "$ certbot renew --dry-run"

    # Avoid false failures when another certbot run is already active.
    while as_root pgrep -f '/usr/bin/certbot renew --dry-run' >/dev/null 2>&1; do
        if [[ "$waited" -ge "$lock_wait_seconds" ]]; then
            echo "Timed out waiting for existing certbot process after ${lock_wait_seconds}s"
            return 1
        fi

        echo "certbot is already running; waiting 5s..."
        sleep 5
        waited=$((waited + 5))
    done

    as_root certbot renew --dry-run || return 1
}

echo "Starting LocalBoost production verification..."
echo "Domain: $DOMAIN"
echo "Service: $SERVICE"

run_check "1) systemd service running" check_systemd_service
run_check "2) nginx configuration valid" check_nginx_config
run_check "3) gunicorn responding" check_gunicorn_response
run_check "4) PostgreSQL connection working" check_postgresql_connection
run_check "5) Django migrations applied" check_migrations_applied
run_check "6) static files served" check_static_files_served
run_check "7) media upload working" check_media_upload
run_check "8) HTTPS active" check_https_active
run_check "9) API endpoint reachable" check_api_endpoint
run_check "10) certbot renewal dry-run" check_certbot_renewal

echo
echo "Verification summary: PASS=$PASS_COUNT FAIL=$FAIL_COUNT"

if [[ "$FAIL_COUNT" -gt 0 ]]; then
    exit 1
fi

exit 0