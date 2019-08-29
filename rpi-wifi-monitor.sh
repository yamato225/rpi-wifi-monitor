#!/bin/bash

cd /opt/rpi-wifi-monitor
source rpi-wifi-monitor.conf

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
    echo "off_ap"
    [ $(pgrep hostapd | wc -l) -gt 0 ] && killall hostapd
    systemctl stop dnsmasq
    systemctl stop dhcpcd
    systemctl ifconfig wlan0 down
}

on_ap() {
    echo "on_ap"
    # set static address to wlan0
    cat << EOL >> /etc/dhcpcd.conf
    interface wlan0
    static ip_address=172.24.1.1/24
    static routers=172.24.1.1
    static domain_name_servers=172.24.1.1
    static broadcast 172.24.1.255
EOL
    ifconfig wlan0 up
    systemctl daemon-reload
    systemctl restart dhcpcd
    # remove static address config for wifi
    systemctl restart dnsmasq
    # set ssid name = hostname
    sed -i -e "s/ssid=\(.*\)/ssid=$(hostname)ap/g" /etc/hostapd/hostapd.conf
    head -n -5 /etc/dhcpcd.conf | tee /etc/dhcpcd.conf > /dev/null
    hostapd /etc/hostapd/hostapd.conf
}

off_wifi() {
    echo "off_wifi"
    systemctl daemon-reload
    systemctl stop wpa_supplicant
    systemctl stop dhcpcd
    ifconfig wlan0 down
}

on_wifi() {
    echo "on_wifi"
    systemctl ifconfig wlan0 up
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
