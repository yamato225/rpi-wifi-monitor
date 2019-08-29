# rpi-wifi-monitor

# これは何？

Raspberry Piのwifi接続を監視するスクリプトです。
定期的に接続状態を確認し、Raspberry Piがwifiに接続できない時、Raspberry Pi自体がwifiのアクセスポイントにします。
つまり、スマートフォン等をRaspberry Piに接続してRaspberry Piを操作することが可能となります。
例えば外出先でRaspberry Piをwifiに接続したいときにスマートフォンのみでwifiの設定ができます。

# インストール

Raspberry Piのコンソールで以下を実行します。

```
git clone https://github.com/yamato225/rpi-wifi-monitor
sudo bash rpi-wifi-monitor/install.sh
sudo rm -rf rpi-wifi-monitor
```

# 使い方

以下でサービスが立ち上がります。

```
sudo systemctl start rpi-wifi-monitor
```

* wifi設定がされていないとき、アクセスポイントモードを開始します。
* wifi設定がされているとき、インターネットに接続可能か確認します。接続できない場合、アクセスポイントモードを開始します。
* 5分ごとにインターネット接続可能かを確認し、接続できない場合アクセスポイントモードを開始します。

# 設定

`/opt/rpi-wifi-monitor/rpi-wifi-monitor.conf`を参照してください。