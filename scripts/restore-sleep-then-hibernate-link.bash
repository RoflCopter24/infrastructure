#!/bin/bash
# This script symlinks the systemd-suspend-then-hibernate.service to the systemd-suspend.service
# GNOME does not allow for a manual selection of 'suspend-then-hibernate',
# it will invoke 'systemctl suspend' no matter what.

echo "Restoring symlink from systemd-suspend-then-hibernate.service to systemd-suspend.service"
rm /usr/lib/systemd/system/systemd-suspend.service
ln -s /usr/lib/systemd/system/systemd-suspend-then-hibernate.service /usr/lib/systemd/system/systemd-suspend.service
