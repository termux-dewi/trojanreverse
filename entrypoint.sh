#!/bin/bash
set -e

echo "Starting nginx in screen..."
# Start nginx in detached screen
screen -dmS nginx /usr/sbin/nginx -g "daemon off;"

# Wait a few seconds to ensure nginx started
sleep 3

echo "Starting Xray Trojan WS..."
# Start Xray (foreground)
exec /usr/local/bin/xray run -c /etc/xray/config.json
