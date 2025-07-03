#!/bin/bash

set -e

APP_DIR="$HOME/Kokoro-FastAPI"
REPO_URL="https://github.com/remsky/Kokoro-FastAPI.git"
SERVICE_NAME="kokoro-fastapi"
START_SCRIPT="$APP_DIR/start-cpu.sh"  # or use start-gpu.sh
USER_NAME=$(whoami)

echo "=== Installing system dependencies ==="
sudo apt update
sudo apt install -y git curl espeak-ng python3 python3-pip

echo "=== Installing astral-uv ==="
curl -LsSf https://astral.sh/uv/install.sh | sh

echo "=== Cloning repository ==="
#git clone "$REPO_URL" "$APP_DIR"
cd "$APP_DIR"

uv pip install -e ".[cpu]"
pip install uvicorn
pip install loguru

echo "=== Creating systemd service ==="
SERVICE_FILE="/etc/systemd/system/${SERVICE_NAME}.service"
sudo bash -c "cat > $SERVICE_FILE" <<EOF
[Unit]
Description=FastAPI TTS Server (Kokoro)
After=network.target

[Service]
Type=simple
User=$USER_NAME
WorkingDirectory=$APP_DIR
ExecStart=$START_SCRIPT
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

echo "=== Enabling and starting service ==="
sudo systemctl daemon-reexec
sudo systemctl daemon-reload
sudo systemctl enable "$SERVICE_NAME"
sudo systemctl start "$SERVICE_NAME"

echo "✅ Setup complete. The service is now running as '$SERVICE_NAME'"
