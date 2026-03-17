#!/usr/bin/env bash
set -euo pipefail

BASE="${BASE:-https://sirius-djibouti.com/api/v1/shops}"
SEARCH_NAME="${SEARCH_NAME:-ocean}"
EXPECTED_SLUG="${EXPECTED_SLUG:-ocean-cafe-seed}"
CURL_MAX_TIME="${CURL_MAX_TIME:-45}"
CURL_RETRY="${CURL_RETRY:-1}"
SHOW_BODIES="${SHOW_BODIES:-0}"
ALLOW_EMPTY_RESULTS="${ALLOW_EMPTY_RESULTS:-0}"

LIST_BODY="$(mktemp)"
SEARCH_BODY="$(mktemp)"
DETAIL_BODY="$(mktemp)"

cleanup() {
  rm -f "$LIST_BODY" "$SEARCH_BODY" "$DETAIL_BODY"
}
trap cleanup EXIT

LIST_STATUS="$(curl -sS --retry "$CURL_RETRY" --retry-delay 1 --max-time "$CURL_MAX_TIME" -o "$LIST_BODY" -w '%{http_code}' "$BASE/" || true)"
SEARCH_STATUS="$(curl -sS --retry "$CURL_RETRY" --retry-delay 1 --max-time "$CURL_MAX_TIME" -o "$SEARCH_BODY" -w '%{http_code}' --get --data-urlencode "name=$SEARCH_NAME" "$BASE/search/" || true)"
LIST_STATUS="${LIST_STATUS:-000}"
SEARCH_STATUS="${SEARCH_STATUS:-000}"

LIST_PARSE_RESULT="$(python3 - "$LIST_BODY" <<'PY'
import json
import sys

path = sys.argv[1]
first_id = ''
json_ok = True

try:
    with open(path, encoding='utf-8') as f:
        payload = json.load(f)
except Exception:
    json_ok = False
    payload = None

if isinstance(payload, list) and payload:
    first_id = str(payload[0].get('id', ''))
elif isinstance(payload, dict) and isinstance(payload.get('results'), list) and payload['results']:
    first_id = str(payload['results'][0].get('id', ''))

print(f"{first_id}|{'true' if json_ok else 'false'}")
PY
)"
FIRST_ID="${LIST_PARSE_RESULT%%|*}"
LIST_JSON_OK="${LIST_PARSE_RESULT#*|}"
if [[ "$LIST_JSON_OK" == "$LIST_PARSE_RESULT" ]]; then
  LIST_JSON_OK="false"
fi

DETAIL_STATUS="N/A"
if [[ -n "$FIRST_ID" ]]; then
    DETAIL_STATUS="$(curl -sS --retry "$CURL_RETRY" --retry-delay 1 --max-time "$CURL_MAX_TIME" -o "$DETAIL_BODY" -w '%{http_code}' "$BASE/$FIRST_ID/" || true)"
    DETAIL_STATUS="${DETAIL_STATUS:-000}"
fi

SEARCH_PARSE_RESULT="$(python3 - "$SEARCH_BODY" "$EXPECTED_SLUG" <<'PY'
import json
import sys

path = sys.argv[1]
expected_slug = sys.argv[2]
json_ok = True

try:
    with open(path, encoding='utf-8') as f:
        payload = json.load(f)
except Exception:
    json_ok = False
    payload = None

if isinstance(payload, dict) and isinstance(payload.get('results'), list):
    items = payload['results']
elif isinstance(payload, list):
    items = payload
else:
    items = []

if not expected_slug:
    has_expected = 'true'
else:
    has_expected = 'true' if any((item or {}).get('slug') == expected_slug for item in items) else 'false'

print(f"{has_expected}|{'true' if json_ok else 'false'}")
PY
)"
SEARCH_HAS_EXPECTED="${SEARCH_PARSE_RESULT%%|*}"
SEARCH_JSON_OK="${SEARCH_PARSE_RESULT#*|}"
if [[ "$SEARCH_JSON_OK" == "$SEARCH_PARSE_RESULT" ]]; then
  SEARCH_JSON_OK="false"
fi

DETAIL_FLAGS="unknown"
DETAIL_JSON_OK="false"
if [[ -n "$FIRST_ID" && -s "$DETAIL_BODY" ]]; then
  DETAIL_PARSE_RESULT="$(python3 - "$DETAIL_BODY" <<'PY'
import json
import sys

path = sys.argv[1]
json_ok = True

try:
    with open(path, encoding='utf-8') as f:
        payload = json.load(f)
except Exception:
    json_ok = False
    payload = {}

has_deals = bool(payload.get('has_active_deals', False))
has_loyalty = bool(payload.get('has_loyalty_programs', False))
slug = payload.get('slug', '')
flags = f'slug={slug} deals={str(has_deals).lower()} loyalty={str(has_loyalty).lower()}'
print(f"{flags}|{'true' if json_ok else 'false'}")
PY
)"
  DETAIL_FLAGS="${DETAIL_PARSE_RESULT%%|*}"
  DETAIL_JSON_OK="${DETAIL_PARSE_RESULT#*|}"
  if [[ "$DETAIL_JSON_OK" == "$DETAIL_PARSE_RESULT" ]]; then
    DETAIL_JSON_OK="false"
  fi
fi

echo "LIST_STATUS=$LIST_STATUS"
echo "SEARCH_STATUS=$SEARCH_STATUS"
echo "ALLOW_EMPTY_RESULTS=$ALLOW_EMPTY_RESULTS"
echo "LIST_JSON_OK=$LIST_JSON_OK"
echo "SEARCH_JSON_OK=$SEARCH_JSON_OK"
echo "FIRST_ID=$FIRST_ID"
echo "DETAIL_STATUS=$DETAIL_STATUS"
echo "DETAIL_JSON_OK=$DETAIL_JSON_OK"
echo "SEARCH_HAS_EXPECTED=$SEARCH_HAS_EXPECTED"
echo "DETAIL_FLAGS=$DETAIL_FLAGS"
if [[ "$SHOW_BODIES" == "1" ]]; then
    echo "LIST_BODY=$(cat "$LIST_BODY")"
    echo "SEARCH_BODY=$(cat "$SEARCH_BODY")"
    if [[ -s "$DETAIL_BODY" ]]; then
        echo "DETAIL_BODY=$(cat "$DETAIL_BODY")"
    fi
fi

PASS=true
[[ "$LIST_STATUS" == "200" ]] || PASS=false
[[ "$SEARCH_STATUS" == "200" ]] || PASS=false
[[ "$LIST_JSON_OK" == "true" ]] || PASS=false
[[ "$SEARCH_JSON_OK" == "true" ]] || PASS=false

if [[ "$ALLOW_EMPTY_RESULTS" == "1" ]]; then
    if [[ -n "$FIRST_ID" ]]; then
        [[ "$DETAIL_STATUS" == "200" ]] || PASS=false
        [[ "$DETAIL_JSON_OK" == "true" ]] || PASS=false
    fi
    if [[ -n "$EXPECTED_SLUG" ]]; then
        [[ "$SEARCH_HAS_EXPECTED" == "true" ]] || PASS=false
    fi
else
    [[ -n "$FIRST_ID" ]] || PASS=false
    [[ "$DETAIL_STATUS" == "200" ]] || PASS=false
    [[ "$DETAIL_JSON_OK" == "true" ]] || PASS=false
    [[ "$SEARCH_HAS_EXPECTED" == "true" ]] || PASS=false
fi

if [[ "$PASS" == true ]]; then
  echo "VERDICT=PASS"
  exit 0
fi

echo "VERDICT=FAIL"
exit 2
