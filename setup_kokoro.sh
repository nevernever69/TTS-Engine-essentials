#!/bin/bash

set -e

APP_DIR="$HOME/Kokoro-FastAPI"
REPO_URL="https://github.com/remsky/Kokoro-FastAPI.git"
SERVICE_NAME="kokoro-fastapi"
START_SCRIPT="$APP_DIR/start-cpu.sh"  # Change to start-gpu.sh if needed
USER_NAME=$(whoami)

echo "=== 🧰 Installing system dependencies ==="
sudo apt update
sudo apt install -y git curl espeak-ng python3 python3-pip

echo "=== 🌌 Installing astral uv ==="
if ! command -v uv &> /dev/null; then
    curl -LsSf https://astral.sh/uv/install.sh | sh
else
    echo "✅ uv already installed."
fi

echo "=== 📦 Cloning Kokoro-FastAPI ==="
if [ ! -d "$APP_DIR" ]; then
    git clone "$REPO_URL" "$APP_DIR"
else
    echo "✅ Repo already cloned at $APP_DIR"
fi

cd "$APP_DIR"

echo "=== 🐍 Installing Python dependencies ==="
uv pip install -e ".[cpu]"
pip install uvicorn loguru

echo "=== 🔧 Creating systemd service ==="
SERVICE_FILE="/etc/systemd/system/${SERVICE_NAME}.service"

sudo tee "$SERVICE_FILE" > /dev/null <<EOF
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

echo "=== 🚀 Enabling and starting $SERVICE_NAME ==="
sudo systemctl daemon-reexec
sudo systemctl daemon-reload
sudo systemctl enable "$SERVICE_NAME"
sudo systemctl start "$SERVICE_NAME"

echo "✅ Kokoro FastAPI is now installed and running as a service: $SERVICE_NAME"
