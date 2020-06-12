#!/bin/bash
systemctl stop restartsock.service
systemctl disable restartsock.service

rm -v /etc/systemd/system/restartsock.service
rm -v /usr/bin/restartsock.sh 
rm -v /etc/logrotate.d/restartsock 

