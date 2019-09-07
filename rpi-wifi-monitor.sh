#!/bin/bash

cd /opt/rpi-wifi-monitor
source rpi-wifi-monitor.conf

WIFI_IP=""

# check wpa_supplicant.conf
# return 0 if wpa_supplicant.conf is not set.
check_config_file() {
    echo $(grep "ssid" /etc/wpa_supplicant/wpa_supplicant.conf | wc -l)
}

# check connection.
# return 0 if ping command failed repeatedly.
check_connection() {
    WIFI_IP=`hostname -I | awk '{print $1}'`
    for (( i=0; i < $CHECK_CONNECTION_TRY_NUM ; i++ ))
    do
        ping $CHECK_CONNECTION_TARGET_IP -c 1 > /dev/null
        [ $? -lt 1 ] && echo 1 && exit
        sleep 1
    done
    echo 0
}

off_ap() {
    echo "off_ap"
    #ip addr del 172.24.1.1 dev wlan0
    [ $(pgrep hostapd | wc -l) -gt 0 ] && killall hostapd
    systemctl stop dnsmasq
    systemctl stop dhcpcd
}

on_ap() {
    echo "on_ap"
    # set static address to wlan0
    if [ $(grep AP_CONFIG /etc/dhcpcd.conf | wc -l) -lt 1 ];then
	cat << EOL | tee -a /etc/dhcpcd.conf
interface wlan0                        #AP_CONFIG
static ip_address=172.24.1.1/24        #AP_CONFIG
static routers=172.24.1.1              #AP_CONFIG
static domain_name_servers=172.24.1.1  #AP_CONFIG
static broadcast 172.24.1.255          #AP_CONFIG
EOL
    fi
    systemctl daemon-reload
    systemctl restart dhcpcd
    # remove static address config for wifi
    while true
    do
        [ $(hostname -I | grep 172.24.1.1 | wc -l) -gt 0 ] && break
        echo "preparing to restart adaptor"
        sleep 1
    done
    systemctl restart dnsmasq
    bash -c "sleep 3 && systemctl restart avahi-daemon" &
    sed -i -e "s/ssid=\(.*\)/ssid=$(hostname)ap/g" /etc/hostapd/hostapd.conf
    hostapd /etc/hostapd/hostapd.conf
}

off_wifi() {
    echo "off_wifi"
    ip addr del $WIFI_IP dev wlan0
    [ -e /opt/rpi-wifi-monitor/10-wpa_supplicant ] || cp -f /lib/dhcpcd/dhcpcd-hooks/10-wpa_supplicant /opt/rpi-wifi-monitor/
    rm -f /lib/dhcpcd/dhcpcd-hooks/10-wpa_supplicant
    systemctl daemon-reload
    systemctl stop wpa_supplicant
    systemctl stop dhcpcd
}

on_wifi() {
    echo "on_wifi"
    grep -v "AP_CONFIG" /etc/dhcpcd.conf > /tmp/dhcpcd.conf.tmp
    cp /tmp/dhcpcd.conf.tmp /etc/dhcpcd.conf
    cp /opt/rpi-wifi-monitor/10-wpa_supplicant /lib/dhcpcd/dhcpcd-hooks/
    systemctl daemon-reload
    systemctl restart dhcpcd
    systemctl restart wpa_supplicant
    systemctl restart avahi-daemon
}

interval_connect_check() {
    while true
    do
        [ $(check_connection) -lt 1 ] && echo "lost connection!" && off_wifi && on_ap
        sleep $CHECK_INTERVAL_SEC
    done
}

# activate wifi

if [ "$WIFI_MODE" = "wifi" ];then
    if [ $(check_config_file) -gt 0 ];then
        echo "wpa_supplicant.conf is set. wifi mode activating..."
        off_ap
        on_wifi
        echo "starting connection check."
        interval_connect_check
    else
        echo "wpa_supplicant.conf is not set. AP mode activating..."
        off_wifi
        on_ap
    fi
else
    echo "start ap mode."
    off_wifi
    on_ap
fi
