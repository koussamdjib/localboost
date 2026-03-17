#!/usr/bin/env bash
set -euo pipefail

REMOTE_BACKEND_DIR="/srv/localboost/backend"
REMOTE_ACCOUNTS_DIR="$REMOTE_BACKEND_DIR/apps/accounts"
ENV_FILE="/etc/localboost/localboost-backend.env"
TS="$(date +%Y%m%d_%H%M%S)"
SHOW_BODIES="${SHOW_BODIES:-0}"
REDACT_TOKENS="${REDACT_TOKENS:-1}"
CURL_MAX_TIME="${CURL_MAX_TIME:-45}"
CURL_RETRY="${CURL_RETRY:-1}"

SER_FILE="$REMOTE_ACCOUNTS_DIR/serializers.py"
VIEWS_FILE="$REMOTE_ACCOUNTS_DIR/views.py"
URLS_FILE="$REMOTE_ACCOUNTS_DIR/urls.py"

SER_BAK="${SER_FILE}.bak.${TS}"
VIEWS_BAK="${VIEWS_FILE}.bak.${TS}"
URLS_BAK="${URLS_FILE}.bak.${TS}"

print_section() {
  echo
  echo "========== $1 =========="
}

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

print_section "1) SSH preflight (remote context)"
whoami
hostname
pwd

print_section "2) Create timestamped backups"
sudo cp -a "$SER_FILE" "$SER_BAK"
sudo cp -a "$VIEWS_FILE" "$VIEWS_BAK"
sudo cp -a "$URLS_FILE" "$URLS_BAK"
echo "Backups created:"
echo "- $SER_BAK"
echo "- $VIEWS_BAK"
echo "- $URLS_BAK"

print_section "3) Inspect current contents before replacement"
echo "--- BEFORE serializers.py (first 80 lines) ---"
sudo sed -n '1,80p' "$SER_FILE"
echo "--- BEFORE views.py (first 120 lines) ---"
sudo sed -n '1,120p' "$VIEWS_FILE"
echo "--- BEFORE urls.py (first 120 lines) ---"
sudo sed -n '1,120p' "$URLS_FILE"

print_section "4) Restore serializers.py"
sudo tee "$SER_FILE" >/dev/null <<'PYEOF'
from django.contrib.auth import get_user_model
from django.contrib.auth.password_validation import validate_password
from django.core import exceptions as django_exceptions
from django.db.models import Sum
from rest_framework import serializers

User = get_user_model()


class UserSerializer(serializers.ModelSerializer):
    name = serializers.SerializerMethodField()
    qr_code_id = serializers.SerializerMethodField()
    total_stamps = serializers.SerializerMethodField()
    total_rewards_redeemed = serializers.SerializerMethodField()
    total_offers_joined = serializers.SerializerMethodField()

    class Meta:
        model = User
        fields = [
            "id",
            "email",
            "name",
            "phone_number",
            "qr_code_id",
            "created_at",
            "last_login",
            "total_stamps",
            "total_rewards_redeemed",
            "total_offers_joined",
        ]
        read_only_fields = [
            "id",
            "email",
            "created_at",
            "last_login",
            "qr_code_id",
            "total_stamps",
            "total_rewards_redeemed",
            "total_offers_joined",
        ]

    def get_name(self, obj):
        if obj.first_name and obj.last_name:
            return f"{obj.first_name} {obj.last_name}"
        return obj.username or obj.email.split("@")[0]

    def get_qr_code_id(self, obj):
        return str(obj.id)

    def get_total_stamps(self, obj):
        if not hasattr(obj, "customer_profile"):
            return 0

        from apps.transactions.models import StampTransaction

        total = StampTransaction.objects.filter(
            enrollment__customer=obj.customer_profile
        ).aggregate(total=Sum("quantity"))["total"]
        return total or 0

    def get_total_rewards_redeemed(self, obj):
        if not hasattr(obj, "customer_profile"):
            return 0

        from apps.rewards.models import RewardRedemption, RedemptionStatus

        return RewardRedemption.objects.filter(
            enrollment__customer=obj.customer_profile,
            status=RedemptionStatus.FULFILLED,
        ).count()

    def get_total_offers_joined(self, obj):
        if not hasattr(obj, "customer_profile"):
            return 0

        from apps.enrollments.models import Enrollment

        return Enrollment.objects.filter(customer=obj.customer_profile).count()


class UserRegistrationSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True, required=True, style={"input_type": "password"})
    name = serializers.CharField(write_only=True, required=False, allow_blank=True)

    class Meta:
        model = User
        fields = ["email", "password", "name", "phone_number"]

    def validate_password(self, value):
        try:
            validate_password(value)
        except django_exceptions.ValidationError as e:
            raise serializers.ValidationError(list(e.messages))
        return value

    def validate_email(self, value):
        if User.objects.filter(email__iexact=value).exists():
            raise serializers.ValidationError("A user with this email already exists.")
        return value.lower()

    def create(self, validated_data):
        from apps.customers.models import CustomerProfile

        name = validated_data.pop("name", "")
        password = validated_data.pop("password")

        if "username" not in validated_data:
            validated_data["username"] = validated_data["email"].split("@")[0]

        user = User.objects.create_user(password=password, **validated_data)

        if name:
            parts = name.strip().split(None, 1)
            user.first_name = parts[0]
            if len(parts) > 1:
                user.last_name = parts[1]
            user.save(update_fields=["first_name", "last_name"])

        CustomerProfile.objects.create(
            user=user,
            first_name=user.first_name,
            last_name=user.last_name,
        )

        return user


class UserUpdateSerializer(serializers.ModelSerializer):
    name = serializers.CharField(required=False, allow_blank=True)

    class Meta:
        model = User
        fields = ["name", "phone_number"]

    def update(self, instance, validated_data):
        name = validated_data.pop("name", None)

        if "phone_number" in validated_data:
            instance.phone_number = validated_data["phone_number"]

        if name is not None:
            parts = name.strip().split(None, 1) if name else []
            instance.first_name = parts[0] if len(parts) > 0 else ""
            instance.last_name = parts[1] if len(parts) > 1 else ""

        instance.save()
        return instance


class ChangePasswordSerializer(serializers.Serializer):
    old_password = serializers.CharField(write_only=True, required=True, style={"input_type": "password"})
    new_password = serializers.CharField(write_only=True, required=True, style={"input_type": "password"})

    def validate_old_password(self, value):
        user = self.context["request"].user
        if not user.check_password(value):
            raise serializers.ValidationError("Old password is incorrect.")
        return value

    def validate_new_password(self, value):
        try:
            validate_password(value, user=self.context["request"].user)
        except django_exceptions.ValidationError as e:
            raise serializers.ValidationError(list(e.messages))
        return value

    def save(self):
        user = self.context["request"].user
        user.set_password(self.validated_data["new_password"])
        user.save(update_fields=["password"])
        return user
PYEOF

print_section "5) Restore views.py"
sudo tee "$VIEWS_FILE" >/dev/null <<'PYEOF'
from rest_framework import generics, status
from rest_framework.permissions import AllowAny, IsAuthenticated
from rest_framework.response import Response
from rest_framework.views import APIView

from apps.accounts.serializers import (
    ChangePasswordSerializer,
    UserRegistrationSerializer,
    UserSerializer,
    UserUpdateSerializer,
)


class UserRegistrationView(generics.CreateAPIView):
    permission_classes = [AllowAny]
    serializer_class = UserRegistrationSerializer

    def create(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        user = serializer.save()

        user_serializer = UserSerializer(user)
        headers = self.get_success_headers(user_serializer.data)
        return Response(
            user_serializer.data,
            status=status.HTTP_201_CREATED,
            headers=headers,
        )


class CurrentUserView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        serializer = UserSerializer(request.user)
        return Response(serializer.data, status=status.HTTP_200_OK)

    def put(self, request):
        serializer = UserUpdateSerializer(
            request.user,
            data=request.data,
            partial=True,
        )
        serializer.is_valid(raise_exception=True)
        serializer.save()

        user_serializer = UserSerializer(request.user)
        return Response(user_serializer.data, status=status.HTTP_200_OK)

    def delete(self, request):
        user = request.user
        user.is_active = False
        user.save(update_fields=["is_active"])
        return Response(status=status.HTTP_204_NO_CONTENT)


class ChangePasswordView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request):
        serializer = ChangePasswordSerializer(
            data=request.data,
            context={"request": request},
        )
        serializer.is_valid(raise_exception=True)
        serializer.save()

        return Response(
            {"message": "Password changed successfully."},
            status=status.HTTP_200_OK,
        )
PYEOF

print_section "6) Restore urls.py"
sudo tee "$URLS_FILE" >/dev/null <<'PYEOF'
from django.urls import path
from rest_framework.permissions import AllowAny
from rest_framework_simplejwt.views import TokenObtainPairView, TokenRefreshView

from apps.accounts.views import (
    ChangePasswordView,
    CurrentUserView,
    UserRegistrationView,
)


class PublicTokenObtainPairView(TokenObtainPairView):
    permission_classes = [AllowAny]


class PublicTokenRefreshView(TokenRefreshView):
    permission_classes = [AllowAny]


urlpatterns = [
    path("register/", UserRegistrationView.as_view(), name="user-register"),
    path("token/", PublicTokenObtainPairView.as_view(), name="token-obtain-pair"),
    path("token/refresh/", PublicTokenRefreshView.as_view(), name="token-refresh"),
    path("me/", CurrentUserView.as_view(), name="current-user"),
    path("me/password/", ChangePasswordView.as_view(), name="change-password"),
]
PYEOF

print_section "7) Verify restored files"
echo "--- AFTER serializers.py (first 220 lines) ---"
sudo sed -n '1,220p' "$SER_FILE"
echo "--- AFTER views.py (first 220 lines) ---"
sudo sed -n '1,220p' "$VIEWS_FILE"
echo "--- AFTER urls.py (first 180 lines) ---"
sudo sed -n '1,180p' "$URLS_FILE"

print_section "8) Apply CORS fix"
CORS_VALUE="https://client.localboost.com,https://merchant.localboost.com,https://sirius-djibouti.com"
if sudo test -f "$ENV_FILE"; then
  sudo cp -a "$ENV_FILE" "${ENV_FILE}.bak.${TS}"
  sudo awk '!/^DJANGO_CORS_ALLOWED_ORIGINS=/' "$ENV_FILE" | sudo tee "$ENV_FILE" >/dev/null
  echo "DJANGO_CORS_ALLOWED_ORIGINS=${CORS_VALUE}" | sudo tee -a "$ENV_FILE" >/dev/null
  echo "Effective CORS env line:"
  sudo grep -n '^DJANGO_CORS_ALLOWED_ORIGINS=' "$ENV_FILE"
else
  echo "WARN: $ENV_FILE not found; skipping env update"
fi

print_section "9) Django checks + restart services"
cd "$REMOTE_BACKEND_DIR"
echo "Reading env file: $ENV_FILE"
if ! sudo test -f "$ENV_FILE"; then
    echo "ERROR: Missing env file: $ENV_FILE"
    exit 1
fi

echo "Detected DJANGO_SETTINGS_MODULE line(s):"
sudo grep -nE '^[[:space:]]*(export[[:space:]]+)?DJANGO_SETTINGS_MODULE=' "$ENV_FILE" || true

echo "Existing settings files under $REMOTE_BACKEND_DIR/config/settings:"
mapfile -t SETTINGS_FILES < <(sudo find "$REMOTE_BACKEND_DIR/config/settings" -maxdepth 1 -type f -name '*.py' -printf '%f\n' | LC_ALL=C sort)
if [[ "${#SETTINGS_FILES[@]}" -eq 0 ]]; then
    echo "(none found)"
else
    printf '%s\n' "${SETTINGS_FILES[@]}"
fi

extract_settings_from_env_file() {
    sudo awk -F= '
        /^[[:space:]]*(export[[:space:]]+)?DJANGO_SETTINGS_MODULE[[:space:]]*=/ {
            sub(/^[[:space:]]*(export[[:space:]]+)?DJANGO_SETTINGS_MODULE[[:space:]]*=[[:space:]]*/, "", $0)
            sub(/[[:space:]]*#.*/, "", $0)
            gsub(/^[[:space:]]+|[[:space:]]+$/, "", $0)
            if ((substr($0, 1, 1) == "\"" && substr($0, length($0), 1) == "\"") || (substr($0, 1, 1) == "\047" && substr($0, length($0), 1) == "\047")) {
                $0 = substr($0, 2, length($0) - 2)
            }
            print $0
            exit
        }
    ' "$ENV_FILE"
}

extract_settings_from_wsgi_file() {
    sudo awk '
        /os\.environ\.setdefault\([[:space:]]*"DJANGO_SETTINGS_MODULE"/ {
            line = $0
            sub(/.*DJANGO_SETTINGS_MODULE"[[:space:]]*,[[:space:]]*"/, "", line)
            sub(/"\).*/, "", line)
            gsub(/^[[:space:]]+|[[:space:]]+$/, "", line)
            if (length(line) > 0) {
                print line
                exit
            }
        }
    ' "$REMOTE_BACKEND_DIR/config/wsgi.py"
}

validate_settings_module() {
    local candidate="$1"
    [[ -n "$candidate" ]] || return 1

    (
        cd "$REMOTE_BACKEND_DIR"
        sudo -u localboost /srv/localboost/.venv/bin/python manage.py check --settings "$candidate" >/dev/null 2>&1
    )
}

resolve_settings_from_files() {
    local filename
    local module_name

    for filename in "${SETTINGS_FILES[@]}"; do
        if [[ "$filename" == "__init__.py" ]] || [[ "$filename" == "base.py" ]]; then
            continue
        fi

        module_name="config.settings.${filename%.py}"
        if validate_settings_module "$module_name"; then
            echo "$module_name"
            return 0
        fi
    done

    return 1
}

SETTINGS_SOURCE="env_file"
SETTINGS_MODULE="$(extract_settings_from_env_file || true)"
if [[ -z "$SETTINGS_MODULE" ]]; then
    SETTINGS_SOURCE="wsgi_default"
    SETTINGS_MODULE="$(extract_settings_from_wsgi_file || true)"
fi

if [[ -z "$SETTINGS_MODULE" ]]; then
    SETTINGS_SOURCE="settings_files"
    SETTINGS_MODULE="$(resolve_settings_from_files || true)"
fi

if [[ -z "$SETTINGS_MODULE" ]]; then
    echo "ERROR: Could not resolve DJANGO_SETTINGS_MODULE from env file, wsgi.py, or settings files."
    exit 1
fi

if ! validate_settings_module "$SETTINGS_MODULE"; then
    echo "ERROR: Resolved settings module is not importable: $SETTINGS_MODULE"
    exit 1
fi

echo "Effective DJANGO_SETTINGS_MODULE=$SETTINGS_MODULE"
echo "SETTINGS_SOURCE=$SETTINGS_SOURCE"

run_manage() {
    local args=("$@")
    (
        cd "$REMOTE_BACKEND_DIR"
        sudo -u localboost /srv/localboost/.venv/bin/python manage.py "${args[@]}" --settings "$SETTINGS_MODULE"
    )
}

run_manage check
run_manage migrate --plan

if ! sudo systemctl restart localboost-backend; then
  echo "localboost-backend restart failed. Logs:"
  sudo systemctl status localboost-backend --no-pager -l || true
  sudo journalctl -u localboost-backend -n 200 --no-pager || true
  exit 1
fi

if ! sudo nginx -t; then
  echo "nginx config test failed. Logs:"
  sudo journalctl -u nginx -n 200 --no-pager || true
  exit 1
fi

if ! sudo systemctl restart nginx; then
  echo "nginx restart failed. Logs:"
  sudo systemctl status nginx --no-pager -l || true
  sudo journalctl -u nginx -n 200 --no-pager || true
  exit 1
fi

sudo systemctl is-active localboost-backend
sudo systemctl is-active nginx
sudo systemctl status localboost-backend --no-pager -l | sed -n '1,40p'
sudo systemctl status nginx --no-pager -l | sed -n '1,40p'

print_section "10) Live HTTPS endpoint verification"
BASE="${BASE:-https://sirius-djibouti.com/api/v1/auth}"
EMAIL="vps.verify.${TS}@test.com"
OLD_PASSWORD='TempPass123!'
NEW_PASSWORD='NewPass123!'

register_payload="$(printf '{"email":"%s","password":"%s","name":"VPS Verify User","phone_number":"+253700000010"}' "$EMAIL" "$OLD_PASSWORD")"
login_payload_old="$(printf '{"email":"%s","password":"%s"}' "$EMAIL" "$OLD_PASSWORD")"
put_payload='{"name":"VPS Verify Updated","phone_number":"+253700000011"}'
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

cleanup_verify_tmp() {
    rm -f "$REG_BODY" "$LOGIN_BODY" "$ME_BODY" "$PUT_BODY" "$PASS_BODY" "$LOGIN_NEW_BODY" "$REFRESH_BODY" "$DELETE_BODY"
}
trap cleanup_verify_tmp EXIT

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

print_section "11) CORS verification"
CORS_CLIENT="$(curl -sSI --retry "$CURL_RETRY" --retry-delay 1 --max-time "$CURL_MAX_TIME" -X OPTIONS 'https://sirius-djibouti.com/api/v1/auth/register/' -H 'Origin: https://client.localboost.com' -H 'Access-Control-Request-Method: POST' | tr -d '\r' | awk 'BEGIN{IGNORECASE=1} /^access-control-allow-origin:/ {print $2; exit}' || true)"
CORS_MERCHANT="$(curl -sSI --retry "$CURL_RETRY" --retry-delay 1 --max-time "$CURL_MAX_TIME" -X OPTIONS 'https://sirius-djibouti.com/api/v1/auth/register/' -H 'Origin: https://merchant.localboost.com' -H 'Access-Control-Request-Method: POST' | tr -d '\r' | awk 'BEGIN{IGNORECASE=1} /^access-control-allow-origin:/ {print $2; exit}' || true)"
CORS_DOMAIN="$(curl -sSI --retry "$CURL_RETRY" --retry-delay 1 --max-time "$CURL_MAX_TIME" -X OPTIONS 'https://sirius-djibouti.com/api/v1/auth/register/' -H 'Origin: https://sirius-djibouti.com' -H 'Access-Control-Request-Method: POST' | tr -d '\r' | awk 'BEGIN{IGNORECASE=1} /^access-control-allow-origin:/ {print $2; exit}' || true)"

echo "CORS_CLIENT=$CORS_CLIENT"
echo "CORS_MERCHANT=$CORS_MERCHANT"
echo "CORS_DOMAIN=$CORS_DOMAIN"

print_section "12) Final PASS/FAIL"
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
