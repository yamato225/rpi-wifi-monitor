#!/bin/bash

# install to systemd

apt install hostapd dnsmasq

CLONE_PATH=$(dirname $0)

INSTALL_PATH=/opt/rpi-wifi-monitor

cd $CLONE_PATH
pwd
[ -d $INSTALL_PATH ] && rm -rf $INSTALL_PATH
mkdir -p $INSTALL_PATH
cp -r * $INSTALL_PATH/.

cp /opt/rpi-wifi-monitor/rpi-wifi-monitor.service /etc/systemd/system/.

sudo systemctl disable dhcpcd
sudo systemctl disable wpa_supplicant
sudo systemctl disable dnsmasq

systemctl daemon-reload
systemctl enable rpi-wifi-monitor

echo ""
echo "install script complete"
