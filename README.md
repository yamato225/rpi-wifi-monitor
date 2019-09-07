# rpi-wifi-monitor

English version follows.

## 概要

Raspberry Piをwifiのアクセスポイントとして動作させるスクリプトです。
APモードではRaspberry Piにスマートフォンなどで直接接続し、ssh接続して操作することができます。
また、Wifi接続中はWifi接続の状態を監視し、接続できない場合APモードを開始します。

## サポートバージョン

Raspbian buster

## 動作

### Wifiモード

* `/etc/wpa_supplicant/wpa_supplicant.conf`の設定が有効な時、wifiモードを開始します。
* 5分ごとにインターネット接続を確認します。接続できない時自動的にAPモードを開始します。

### APモード

* "<ホスト名> + ap(例: rasperrypiap)"というSSIDでRPiに接続できます。
* 接続パスワードは"bunbunbun"です。

### インストール方法

RPiがインターネット接続可能な状態で実施してください。

```
git clone https://github.com/yamato225/rpi-wifi-monitor/
cd rpi-wifi-monitor
sudo bash install.sh
sudo systemctl start rpi-wifi-monitor
```

### アンインストール方法

```
sudo rm -f /etc/systemd/system/rpi-wifi-monitor.service
sudo rm -rf /opt/rpi-wifi-monitor
sudo systemctl daemon-reload
```

## What is this?

Script to use RPi as wifi acess point.
On the AP mode, You can operate RPi by connecting the acess point and using ssh.
When RPi connects to wifi, this check Internet connection. When RPi losts Internet connection, this starts AP mode.

## support version

Raspbian buster

## How work is this?

### Wifi Mode

* This script starts wifi connection according to `/etc/wpa_supplicant/wpa_supplicant.conf`
* This script checks Internet connection every 5 minutes. If RPi can't connect to Internet, this starts AP Mode.

### AP Mode

* You can connect a SSID named "\<hostname> + ap (ex. raspberrypiap)".
* the password is "bunbunbun"

## install

You need to connect RPi to Internet.

```
git clone https://github.com/yamato225/rpi-wifi-monitor/
cd rpi-wifi-monitor
sudo bash install.sh
sudo systemctl start rpi-wifi-monitor
```

## uninstall

```
sudo rm -f /etc/systemd/system/rpi-wifi-monitor.service
sudo rm -rf /opt/rpi-wifi-monitor
sudo systemctl daemon-reload
```