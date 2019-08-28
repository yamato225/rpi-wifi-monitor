#!/bin/bash

#cd /opt/rpi-wifi-monitor
cd /home/pi/rpi-wifi-monitor
source rpi-wifi-monitor.conf

CHECK_INTERVAL_SEC=1

# check wpa_supplicant.conf 
# return 0 if wpa_supplicant.conf is not set.
check_config_file() {
    echo $(grep "ssid" /etc/wpa_supplicant/wpa_supplicant.conf | wc -l)
}

# check connection.
# return 0 if ping command failed repeatedly.
check_connection() {
    for (( i=0; i < $CHECK_CONNECTION_TRY_NUM ; i++ ))
    do
        ping $CHECK_CONNECTION_TARGET_IP -c 1 > /dev/null
        [ $? -lt 1 ] && echo 1 && exit
        sleep 1
    done
    echo 0
}

off_ap() {
    [ $(pgrep hostapd | wc -l) -gt 0 ] && killall hostapd
    systemctl stop dnsmasq
    systemctl stop dhcpcd
    systemctl ifconfig wlan0 down
}

on_ap() {
    echo "on_ap"
    cat << EOL >> /etc/dhcpcd.conf
    interface wlan0
    static ip_address=172.24.1.1/24
    static routers=172.24.1.1
    static domain_name_servers=172.24.1.1
    static broadcast 172.24.1.255
EOL
    ifconfig wlan0 up
    hostapd /etc/hostapd/hostapd.conf &
}

off_wifi() {
    [ $(pgrep hostapd | wc -l) -gt 0 ] && killall hostapd
    systemctl daemon-reload
    systemctl stop wpa_supplicant
    systemctl stop dhcpcd
    ifconfig wlan0 down
}

on_wifi() {
    systemctl ifconfig wlan0 up
    systemctl start wpa_supplicant
    sleep 2
    systemctl daemon-reload
    systemctl start dhcpcd
}

to_ap_mode() {
    echo "AP mode activating..."
    off_wifi
    on_ap
}

interval_connect_check() {
    while true
    do
        [ $(check_connection) -lt 1 ] && echo "lost connection!" && to_ap_mode
        sleep $CHECK_INTERVAL_SEC
    done
}

# activate wifi

if [ $(check_config_file) -gt 0 ];then
    echo "wpa_supplicant.conf is set. start to check connection..."
    interval_connect_check
else
    echo "wpa_supplicant.conf is not set. AP mode activating..."
fi
