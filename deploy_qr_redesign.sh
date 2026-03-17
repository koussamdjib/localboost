#!/bin/bash
set -euo pipefail

echo "=== Deploying QR-per-enrollment backend ==="

BACKEND=/srv/localboost/backend
VENV=/srv/localboost/.venv

# Copy app files
sudo cp /tmp/enrollment_models.py    $BACKEND/apps/enrollments/models.py
sudo cp /tmp/enrollment_serializers.py $BACKEND/apps/enrollments/serializers.py
sudo cp /tmp/enrollment_views.py     $BACKEND/apps/enrollments/views.py
sudo cp /tmp/enrollment_urls.py      $BACKEND/apps/enrollments/urls.py
sudo cp /tmp/0002_enrollment_qr_token.py $BACKEND/apps/enrollments/migrations/0002_enrollment_qr_token.py
sudo cp /tmp/transaction_models.py   $BACKEND/apps/transactions/models.py
sudo cp /tmp/0002_stamptransaction_idempotency.py $BACKEND/apps/transactions/migrations/0002_stamptransaction_idempotency.py
sudo cp /tmp/accounts_serializers.py $BACKEND/apps/accounts/serializers.py
echo "Files copied."

# Fix ownership
sudo chown -R localboost:localboost $BACKEND/apps/enrollments $BACKEND/apps/transactions $BACKEND/apps/accounts
echo "Ownership fixed."

# Run migrations
cd $BACKEND
sudo -u localboost $VENV/bin/python manage.py migrate enrollments 0002_enrollment_qr_token --noinput
sudo -u localboost $VENV/bin/python manage.py migrate transactions 0002_stamptransaction_idempotency --noinput
echo "Migrations complete."

# Restart service
sudo systemctl restart localboost-backend
sleep 3
STATUS=$(sudo systemctl is-active localboost-backend)
echo "Service status: $STATUS"

echo "=== Done ==="
