# rpi-ubuntu-serviio
Setup dedicated Serviio server on a Raspberry Pi with Ubuntu server using Ansible.

RaspberryPi をServiio専用サーバとして構成するためのAnsibleコード。
Raspberry-Pi-Imagerで焼き込んだUbuntu Server 21.04 (64bit) に対し、cloud-init調整のためのシェルスクリプトと起動後にネットワーク越しにServiioサーバを構築するためのAnsibleコードからなる。


# 想定環境
- 操作元はmacOSのコンソールを想定。
- Mac上の `raspberry-pi-imager` でイメージを焼き込むことを想定。
- イメージはUbuntu Server 21.04 (64bit)を想定。
	- 当方環境では Ubuntu Server 20.04 LTS では Raspberry Pi の起動が確認できなかったため
- ネットワークは有線LAN/無線LANの両方に対応


# 使い方 (構築方法)

## Step1: microSD(またはUSBドライブ等)の作成と調整
1. raspberry-pi-imager で Ubuntu Server 21.04 (64bit) を書き込む
2. SDカード(またはUSBドライブ等)を一度抜き差しし、再マウント
3. `change-system-boot.sh` を実行
	-  Macであればマウント位置は変更不要のはず `[/Volumes/system-boot]`
	- モニタ解像度を変更する (1:VGA: 3:480p 4:720pデフォルト 16:1080p)
	(参考) https://www.raspberrypi.org/documentation/configuration/config-txt/video.md
	- 無線LANを使用する場合にはSSIDとパスワードを入力
	- 無線LANを使用しない場合にはSSID欄を入力しない
4. SDカード(またはUSBドライブ等)をMacから取り外し、Raspberry Pi にセットして起動

## Step2: ネットワーク越しのサーバ構築
6. Raspberry Piの起動完了までしばらく待つ
	- Wi-Fi設定時は自動的に一度再起動するので3分くらい待つ
7. Raspberry PiのIPアドレスを調べる
8. `hosts.yml` ファイルにIPアドレスを記載する
9. macOSからRaspberry Piにssh接続するための設定
	- 秘密鍵を登録： `ssh-add ~/.ssh/id_rsa`
	- 初回ログインし、デフォルトアカウント(`ubuntu`)のパスワードを変更する
		- `ssh ubuntu@(IPアドレス)`
		- デフォルトパスワードは `ubuntu`
	- 自分のアカウントの公開鍵をコピーする：`ssh-copy-id ubuntu@(IPアドレス)`
	- 鍵によるsshログイン確認：`ssh ubuntu@(IPアドレス)`
10. サーバ構築実行
	- `ansible-playbook -i hosts.yml site.yml`


# Serviioへのアクセス
avahiを導入し、Nginxでポート`:80`からServiioのデフォルトポート`:23423`へのproxyおよびトップ画面のパス`/console`へのリダイレクトを構成しているので、次のURLでServiioトップ画面にアクセスできる

http://serviio.local/

# おまけ
Raspberry Pi 4用ケース「Argon ONE」を利用している場合はのファンコントロールスクリプトのインストールのため`site.yml`の以下の行を有効にする。
```
    - { name: argonone, tags: argonone }
```
