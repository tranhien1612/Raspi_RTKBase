#!/bin/bash

# Check if the script is being run as root
if [ "$EUID" -ne 0 ]; then
    echo "Error: This script must be run as root or with sudo privileges."
    echo "Usage: sudo ./setup.sh"
    exit 1
fi

CURRENT_DIR="$(pwd)"
SERVICE_FILE="/etc/systemd/system/ntrip.service"

echo "Check folder: $CURRENT_DIR/RTKLIB"
if [ ! -d "$CURRENT_DIR/RTKLIB" ]; then
    echo "Error: Source directory '$CURRENT_DIR/RTKLIB' not found."
    exit 1
fi

echo "Building str2str..."
cd $CURRENT_DIR/RTKLIB/app/str2str/gcc && make && cd ../../..

echo "Copy str2str into /user/local/bin"
sudo cp $CURRENT_DIR/RTKLIB/app/str2str/gcc/str2str /usr/local/bin

echo "Check str2str is on /usr/local/bin...."
which str2str

echo "Creating the ntrip.service file..."
cat <<EOF > "$SERVICE_FILE"
[Unit]
Description=Ntrip Caster Startup Script
After=network.target

[Service]
ExecStart=$CURRENT_DIR/run.sh
Restart=always

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable ntrip.service
sudo systemctl start ntrip.service
sudo systemctl status ntrip.service