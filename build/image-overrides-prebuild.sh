#!/usr/bin/bash

# Use this file for setps that need to happen before the 
# reusable scripts run.

echo "Setting up dnf config manager"
dnf install -y 'dnf-command(config-manager)'
