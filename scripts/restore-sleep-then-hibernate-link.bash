#!/bin/bash

echo "Restoring symlink from systemd-suspend-then-hibernate.service to systemd-suspend.service"
rm /usr/lib/systemd/system/systemd-suspend.service
ln -s /usr/lib/systemd/system/systemd-suspend-then-hibernate.service /usr/lib/systemd/system/systemd-suspend.service
