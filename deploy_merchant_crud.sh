#!/bin/bash
# Deploy merchant CRUD files and restart service

echo "================================================================================"
echo "DEPLOYING MERCHANT MULTI-SHOP CRUD TO PRODUCTION"
echo "================================================================================"
echo ""

# 1. Deploy API config
echo "[1] Deploying API URLs configuration..."
sudo cp /tmp/api_urls_deploy.py /srv/localboost/backend/config/api_urls.py && \
sudo chown localboost:localboost /srv/localboost/backend/config/api_urls.py && \
echo "    ✓ api_urls.py deployed"

# 2. Deploy merchant files
echo "[2] Deploying merchant app files..."
for file in serializers permissions views urls; do
    if [ -f "/tmp/${file}.py" ]; then
        sudo cp "/tmp/${file}.py" "/srv/localboost/backend/apps/merchants/${file}.py" && \
        sudo chown localboost:localboost "/srv/localboost/backend/apps/merchants/${file}.py" && \
        echo "    ✓ ${file}.py deployed"
    fi
done

# 3. Deploy shops model
echo "[3] Deploying shops model..."
if [ -f "/tmp/models.py" ]; then
    sudo cp "/tmp/models.py" "/srv/localboost/backend/apps/shops/models.py" && \
    sudo chown localboost:localboost "/srv/localboost/backend/apps/shops/models.py" && \
    echo "    ✓ models.py deployed"
fi

# 4. Restart service
echo "[4] Restarting localboost-backend service..."
sudo systemctl restart localboost-backend
sleep 3

# 5. Verify service status
echo "[5] Verifying service status..."
SERVICE_STATUS=$(sudo systemctl is-active localboost-backend)
if [ "$SERVICE_STATUS" = "active" ]; then
    echo "    ✓ Service running"
else
    echo "    ✗ Service not running - check logs"
    sudo systemctl status localboost-backend --no-pager | head -10
fi

echo ""
echo "================================================================================"
echo "DEPLOYMENT COMPLETE"
echo "================================================================================"
