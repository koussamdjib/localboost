#!/usr/bin/env bash
set -euo pipefail

BASE="${BASE:-https://sirius-djibouti.com/api/v1/auth}"
TS="$(date +%s)"
EMAIL="vps.live.${TS}@test.com"
OLD_PASSWORD='TempPass123!'
NEW_PASSWORD='NewPass123!'
SHOW_BODIES="${SHOW_BODIES:-0}"
REDACT_TOKENS="${REDACT_TOKENS:-1}"
CURL_MAX_TIME="${CURL_MAX_TIME:-45}"
CURL_RETRY="${CURL_RETRY:-1}"

register_payload="$(printf '{"email":"%s","password":"%s","name":"VPS Live Verify","phone_number":"+253700000100"}' "$EMAIL" "$OLD_PASSWORD")"
login_payload_old="$(printf '{"email":"%s","password":"%s"}' "$EMAIL" "$OLD_PASSWORD")"
put_payload='{"name":"VPS Live Updated","phone_number":"+253700000101"}'
pass_payload="$(printf '{"old_password":"%s","new_password":"%s"}' "$OLD_PASSWORD" "$NEW_PASSWORD")"
login_payload_new="$(printf '{"email":"%s","password":"%s"}' "$EMAIL" "$NEW_PASSWORD")"

REG_BODY="$(mktemp)"
LOGIN_BODY="$(mktemp)"
ME_BODY="$(mktemp)"
PUT_BODY="$(mktemp)"
PASS_BODY="$(mktemp)"
LOGIN_NEW_BODY="$(mktemp)"
REFRESH_BODY="$(mktemp)"
DELETE_BODY="$(mktemp)"

cleanup() {
  rm -f "$REG_BODY" "$LOGIN_BODY" "$ME_BODY" "$PUT_BODY" "$PASS_BODY" "$LOGIN_NEW_BODY" "$REFRESH_BODY" "$DELETE_BODY"
}
trap cleanup EXIT

sanitize_json_file() {
  local body_file="$1"

  if [[ "$REDACT_TOKENS" != "1" ]]; then
    cat "$body_file"
    return
  fi

  python3 - "$body_file" <<'PY'
import json
import sys

path = sys.argv[1]

try:
    with open(path, encoding='utf-8') as f:
        payload = json.load(f)
except Exception:
    with open(path, encoding='utf-8', errors='replace') as f:
        print(f.read(), end='')
    sys.exit(0)


def redact(value):
    if isinstance(value, dict):
        out = {}
        for key, item in value.items():
            if key in {"access", "refresh", "token"}:
                out[key] = "***redacted***"
            else:
                out[key] = redact(item)
        return out
    if isinstance(value, list):
        return [redact(item) for item in value]
    return value


print(json.dumps(redact(payload), separators=(',', ':')))
PY
}

print_body() {
  local name="$1"
  local body_file="$2"

  if [[ "$SHOW_BODIES" != "1" ]]; then
    return
  fi

  echo "${name}=$(sanitize_json_file "$body_file")"
}

REGISTER_STATUS="$(curl -sS --retry "$CURL_RETRY" --retry-delay 1 --max-time "$CURL_MAX_TIME" -o "$REG_BODY" -w '%{http_code}' -X POST "$BASE/register/" -H 'Content-Type: application/json' -d "$register_payload" || true)"
LOGIN_STATUS="$(curl -sS --retry "$CURL_RETRY" --retry-delay 1 --max-time "$CURL_MAX_TIME" -o "$LOGIN_BODY" -w '%{http_code}' -X POST "$BASE/token/" -H 'Content-Type: application/json' -d "$login_payload_old" || true)"
REGISTER_STATUS="${REGISTER_STATUS:-000}"
LOGIN_STATUS="${LOGIN_STATUS:-000}"

TOKEN_PARSE_RESULT="$(python3 - "$LOGIN_BODY" <<'PY'
import json
import sys

path = sys.argv[1]
access = ''
refresh = ''
json_ok = True

try:
    with open(path, encoding='utf-8') as f:
        payload = json.load(f)
except Exception:
    payload = {}
    json_ok = False

if isinstance(payload, dict):
    access = payload.get('access', '') or ''
    refresh = payload.get('refresh', '') or ''

print(f"{access}|{refresh}|{'true' if json_ok else 'false'}")
PY
)"

ACCESS=""
REFRESH=""
LOGIN_JSON_OK="false"
IFS='|' read -r ACCESS REFRESH LOGIN_JSON_OK <<< "$TOKEN_PARSE_RESULT"

ME_STATUS="000"
PUT_STATUS="000"
PASS_CHANGE_STATUS="000"
DELETE_STATUS="000"
if [[ -n "$ACCESS" ]]; then
  ME_STATUS="$(curl -sS --retry "$CURL_RETRY" --retry-delay 1 --max-time "$CURL_MAX_TIME" -o "$ME_BODY" -w '%{http_code}' -X GET "$BASE/me/" -H "Authorization: Bearer $ACCESS" || true)"
  PUT_STATUS="$(curl -sS --retry "$CURL_RETRY" --retry-delay 1 --max-time "$CURL_MAX_TIME" -o "$PUT_BODY" -w '%{http_code}' -X PUT "$BASE/me/" -H 'Content-Type: application/json' -H "Authorization: Bearer $ACCESS" -d "$put_payload" || true)"
  PASS_CHANGE_STATUS="$(curl -sS --retry "$CURL_RETRY" --retry-delay 1 --max-time "$CURL_MAX_TIME" -o "$PASS_BODY" -w '%{http_code}' -X POST "$BASE/me/password/" -H 'Content-Type: application/json' -H "Authorization: Bearer $ACCESS" -d "$pass_payload" || true)"
fi
ME_STATUS="${ME_STATUS:-000}"
PUT_STATUS="${PUT_STATUS:-000}"
PASS_CHANGE_STATUS="${PASS_CHANGE_STATUS:-000}"
DELETE_STATUS="${DELETE_STATUS:-000}"

LOGIN_NEW_STATUS="$(curl -sS --retry "$CURL_RETRY" --retry-delay 1 --max-time "$CURL_MAX_TIME" -o "$LOGIN_NEW_BODY" -w '%{http_code}' -X POST "$BASE/token/" -H 'Content-Type: application/json' -d "$login_payload_new" || true)"
LOGIN_NEW_STATUS="${LOGIN_NEW_STATUS:-000}"

REFRESH_STATUS="000"
if [[ -n "$REFRESH" ]]; then
  REFRESH_STATUS="$(curl -sS --retry "$CURL_RETRY" --retry-delay 1 --max-time "$CURL_MAX_TIME" -o "$REFRESH_BODY" -w '%{http_code}' -X POST "$BASE/token/refresh/" -H 'Content-Type: application/json' -d "$(printf '{"refresh":"%s"}' "$REFRESH")" || true)"
fi
REFRESH_STATUS="${REFRESH_STATUS:-000}"

if [[ -n "$ACCESS" ]]; then
  DELETE_STATUS="$(curl -sS --retry "$CURL_RETRY" --retry-delay 1 --max-time "$CURL_MAX_TIME" -o "$DELETE_BODY" -w '%{http_code}' -X DELETE "$BASE/me/" -H "Authorization: Bearer $ACCESS" || true)"
fi
DELETE_STATUS="${DELETE_STATUS:-000}"

CORS_CLIENT="$(curl -sSI --retry "$CURL_RETRY" --retry-delay 1 --max-time "$CURL_MAX_TIME" -X OPTIONS 'https://sirius-djibouti.com/api/v1/auth/register/' -H 'Origin: https://client.localboost.com' -H 'Access-Control-Request-Method: POST' | tr -d '\r' | awk 'BEGIN{IGNORECASE=1} /^access-control-allow-origin:/ {print $2; exit}' || true)"
CORS_MERCHANT="$(curl -sSI --retry "$CURL_RETRY" --retry-delay 1 --max-time "$CURL_MAX_TIME" -X OPTIONS 'https://sirius-djibouti.com/api/v1/auth/register/' -H 'Origin: https://merchant.localboost.com' -H 'Access-Control-Request-Method: POST' | tr -d '\r' | awk 'BEGIN{IGNORECASE=1} /^access-control-allow-origin:/ {print $2; exit}' || true)"
CORS_DOMAIN="$(curl -sSI --retry "$CURL_RETRY" --retry-delay 1 --max-time "$CURL_MAX_TIME" -X OPTIONS 'https://sirius-djibouti.com/api/v1/auth/register/' -H 'Origin: https://sirius-djibouti.com' -H 'Access-Control-Request-Method: POST' | tr -d '\r' | awk 'BEGIN{IGNORECASE=1} /^access-control-allow-origin:/ {print $2; exit}' || true)"

echo "TEST_EMAIL=$EMAIL"
echo "REGISTER_STATUS=$REGISTER_STATUS"
print_body "REGISTER_BODY" "$REG_BODY"
echo "LOGIN_STATUS=$LOGIN_STATUS"
echo "LOGIN_JSON_OK=$LOGIN_JSON_OK"
print_body "LOGIN_BODY" "$LOGIN_BODY"
echo "ME_STATUS=$ME_STATUS"
print_body "ME_BODY" "$ME_BODY"
echo "PUT_STATUS=$PUT_STATUS"
print_body "PUT_BODY" "$PUT_BODY"
echo "PASS_CHANGE_STATUS=$PASS_CHANGE_STATUS"
print_body "PASS_BODY" "$PASS_BODY"
echo "LOGIN_NEW_STATUS=$LOGIN_NEW_STATUS"
print_body "LOGIN_NEW_BODY" "$LOGIN_NEW_BODY"
echo "REFRESH_STATUS=$REFRESH_STATUS"
print_body "REFRESH_BODY" "$REFRESH_BODY"
echo "DELETE_STATUS=$DELETE_STATUS"
print_body "DELETE_BODY" "$DELETE_BODY"

echo "CORS_CLIENT=$CORS_CLIENT"
echo "CORS_MERCHANT=$CORS_MERCHANT"
echo "CORS_DOMAIN=$CORS_DOMAIN"

PASS=true
[ "$REGISTER_STATUS" = "201" ] || PASS=false
[ "$LOGIN_STATUS" = "200" ] || PASS=false
[ "$LOGIN_JSON_OK" = "true" ] || PASS=false
[ "$ME_STATUS" = "200" ] || PASS=false
[ "$PUT_STATUS" = "200" ] || PASS=false
[ "$PASS_CHANGE_STATUS" = "200" ] || PASS=false
[ "$LOGIN_NEW_STATUS" = "200" ] || PASS=false
[ "$REFRESH_STATUS" = "200" ] || PASS=false
[ "$DELETE_STATUS" = "204" ] || PASS=false
[ "$CORS_CLIENT" = "https://client.localboost.com" ] || PASS=false
[ "$CORS_MERCHANT" = "https://merchant.localboost.com" ] || PASS=false
[ "$CORS_DOMAIN" = "https://sirius-djibouti.com" ] || PASS=false

if [ "$PASS" = true ]; then
  echo "VERDICT=PASS"
  exit 0
fi

echo "VERDICT=FAIL"
exit 2
