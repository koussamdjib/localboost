import os

from .base import *

DEBUG = True
ALLOWED_HOSTS = ["*"]

# CORS Configuration for Flutter development
CORS_ALLOW_ALL_ORIGINS = True  # Allow all origins in development
CORS_ALLOW_CREDENTIALS = True

# Alternative: Specify allowed origins explicitly
# CORS_ALLOWED_ORIGINS = [
#     "http://localhost:8080",
#     "http://localhost:3000",
#     "http://127.0.0.1:8080",
#     "http://10.0.2.2:8000",  # Android emulator
# ]

if os.getenv("LOCAL_USE_SQLITE", "true").lower() == "true":
    DATABASES = {
        "default": {
            "ENGINE": "django.db.backends.sqlite3",
            "NAME": BASE_DIR / "db.sqlite3",
        }
    }
