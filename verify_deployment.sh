#!/bin/bash
# Quick verification of deployed files

echo "=== DEPLOYMENT VERIFICATION ==="
echo ""

FILES=(
    "/srv/localboost/backend/config/api_urls.py:API_URLS"
    "/srv/localboost/backend/apps/merchants/serializers.py:SERIALIZERS"
    "/srv/localboost/backend/apps/merchants/permissions.py:PERMISSIONS"
    "/srv/localboost/backend/apps/merchants/views.py:VIEWS"
    "/srv/localboost/backend/apps/merchants/urls.py:URLS"
    "/srv/localboost/backend/apps/shops/models.py:MODELS"
)

for file_info in "${FILES[@]}"; do
    IFS=':' read -r filepath name <<< "$file_info"
    if sudo test -f "$filepath"; then
        echo "✓ $name: Deployed"
    else
        echo "✗ $name: MISSING"
    fi
done

echo ""
echo "Service status:"
sudo systemctl status localboost-backend | head -5
