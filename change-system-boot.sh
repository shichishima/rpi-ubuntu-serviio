#!/bin/bash
#----------------------------------------------------------------
# RaspberryPi初回起動時のためにcloud-initとconfig.txtを調整する。
# SSIDを設定しなければWi-Fiは設定されない。(有線LANでのみ接続可能)
# SSIDとパスワードを設定した場合には無線LAN設定が書き込まれる。
# この場合には初回起動時に一度自動できに再起動が実行される。
#----------------------------------------------------------------

system_boot_path=/Volumes/system-boot
/bin/echo -n "path to system-boot [${system_boot_path}]: "
read str
if [ ! -z ${str} ]; then
    system_boot_path=${str}
fi
if [ ! -d ${system_boot_path} ]; then
    echo ------------------------------------------------------------
    echo The directory does not exist. Did you forget to RE-MOUNT it?
    echo ------------------------------------------------------------
    exit;
fi

hdmi_mode=4
/bin/echo -n "hdmi_mode [${hdmi_mode}]: "
read str
if [ ! -z ${str} ]; then
    hdmi_mode=${str}
fi

wifi_ssid=
wifi_passwd=
wifi_str="(Wired LAN only)"
/bin/echo -n "wifi_ssid [${wifi_ssid}]: "
read str
if [ ! -z ${str} ]; then
    wifi_ssid=${str}
    wifi_str=${str}
    /bin/echo -n "wifi_passwd [${wifi_passwd}]: "
    read str
    wifi_passwd=${str}
fi


cat <<EOF

-----------------------------------------

system_boot_path: ${system_boot_path}
       hdmi_mode: ${hdmi_mode}
       wifi_ssid: ${wifi_str}
    wifi_passwod: ${wifi_passwd}

EOF
/bin/echo -n "OK? (Y/y) "
read str
if [  "${str}" != "Y" ] && [ "${str}" != "y" ]; then
    echo exit.
    exit;
fi

#-------------------------------------------------------
file=config.txt

if [ ! -f ${system_boot_path}/${file}.org ]; then
    cp ${system_boot_path}/${file} ${system_boot_path}/${file}.org
fi
cp ${system_boot_path}/${file}.org ${system_boot_path}/${file}
cat <<EOF >> ${system_boot_path}/${file}

#---------------------
hdmi_force_hotplug=1
hdmi_group=1
hdmi_mode=${hdmi_mode}

EOF

#-------------------------------------------------------
file=network-config

if [ ! -f ${system_boot_path}/${file}.org ]; then
    cp ${system_boot_path}/${file} ${system_boot_path}/${file}.org
fi
cp ${system_boot_path}/${file}.org ${system_boot_path}/${file}
cat <<EOF >> ${system_boot_path}/${file}

#---------------------
wifis:
  wlan0:
    dhcp4: true
    optional: true
    access-points:
      "${wifi_ssid}":
        password: "${wifi_passwd}"

EOF

#-------------------------------------------------------
file=user-data

if [ ! -f ${system_boot_path}/${file}.org ]; then
    cp ${system_boot_path}/${file} ${system_boot_path}/${file}.org
fi
cp ${system_boot_path}/${file}.org ${system_boot_path}/${file}
cat <<EOF >> ${system_boot_path}/${file}

#---------------------
runcmd:
# apply netplan config defined on 'network-config'
- [ netplan, apply ]
- [ reboot ]

EOF
