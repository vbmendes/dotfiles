#!/bin/bash

ENV_FILE="/etc/environment"

grep -q "GTK_IM_MODULE=cedilla" "$ENV_FILE" && grep -q "QT_IM_MODULE=cedilla" "$ENV_FILE" && {
    echo "Cedilla fix already applied."
    exit 0
}

echo "Applying cedilla fix to $ENV_FILE (requires sudo)..."
sudo bash -c '
    grep -q "GTK_IM_MODULE=cedilla" /etc/environment || echo "GTK_IM_MODULE=cedilla" >> /etc/environment
    grep -q "QT_IM_MODULE=cedilla" /etc/environment || echo "QT_IM_MODULE=cedilla" >> /etc/environment
'
echo "Done. Log out and back in for changes to take effect."
