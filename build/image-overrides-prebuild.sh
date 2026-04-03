#!/usr/bin/bash

# Use this file for setps that need to happen before the 
# reusable scripts run.

echo "Setting up dnf config manager"
dnf install -y 'dnf-command(config-manager)'

echo "Setting up usable /usr/local"
rm -rf /usr/local
ln -s /var/usrlocal /usr/local
