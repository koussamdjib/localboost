from django.core.cache import cache
from django.db import connection
from django.db.migrations.executor import MigrationExecutor
from django.utils import timezone
from rest_framework.permissions import AllowAny
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework import status


def _check_database():
    try:
        with connection.cursor() as cursor:
            cursor.execute("SELECT 1")
            cursor.fetchone()
        return {"status": "ok"}
    except Exception as exc:
        return {"status": "error", "error": str(exc)}


def _check_migrations():
    try:
        executor = MigrationExecutor(connection)
        targets = executor.loader.graph.leaf_nodes()
        pending_count = len(executor.migration_plan(targets))
        if pending_count == 0:
            return {"status": "ok", "pending": 0}
        return {
            "status": "error",
            "pending": pending_count,
            "error": "Unapplied migrations detected.",
        }
    except Exception as exc:
        return {"status": "error", "error": str(exc)}


def _check_cache():
    key = f"health:cache:{timezone.now().timestamp()}"
    try:
        cache.set(key, "ok", timeout=10)
        value = cache.get(key)
        cache.delete(key)
        if value == "ok":
            return {"status": "ok"}
        return {"status": "error", "error": "Cache read/write check failed."}
    except Exception as exc:
        return {"status": "error", "error": str(exc)}


def _response_status(*checks):
    return (
        status.HTTP_200_OK
        if all(check.get("status") == "ok" for check in checks)
        else status.HTTP_503_SERVICE_UNAVAILABLE
    )


class HealthCheckView(APIView):
    permission_classes = [AllowAny]

    def get(self, request):
        db_check = _check_database()
        migrations_check = _check_migrations()
        cache_check = _check_cache()

        http_status = _response_status(db_check, migrations_check, cache_check)
        payload = {
            "status": "ok" if http_status == status.HTTP_200_OK else "degraded",
            "service": "localboost-backend",
            "timestamp": timezone.now(),
            "checks": {
                "database": db_check,
                "migrations": migrations_check,
                "cache": cache_check,
            },
        }
        return Response(payload, status=http_status)


class DatabaseHealthCheckView(APIView):
    permission_classes = [AllowAny]

    def get(self, request):
        db_check = _check_database()
        migrations_check = _check_migrations()
        http_status = _response_status(db_check, migrations_check)
        payload = {
            "status": "ok" if http_status == status.HTTP_200_OK else "degraded",
            "service": "localboost-backend",
            "timestamp": timezone.now(),
            "checks": {
                "database": db_check,
                "migrations": migrations_check,
            },
        }
        return Response(payload, status=http_status)


class CacheHealthCheckView(APIView):
    permission_classes = [AllowAny]

    def get(self, request):
        cache_check = _check_cache()
        http_status = _response_status(cache_check)
        payload = {
            "status": "ok" if http_status == status.HTTP_200_OK else "degraded",
            "service": "localboost-backend",
            "timestamp": timezone.now(),
            "checks": {
                "cache": cache_check,
            },
        }
        return Response(payload, status=http_status)
