#!/bin/bash
systemctl stop restartsock
systemctl disable restartsock
cp restartsock.service /etc/systemd/system/
cp restartsock.sh /usr/bin
cp restartsock /etc/logrotate.d/
sudo systemctl enable restartsock.service
sudo systemctl reload-or-restart restartsock.service

