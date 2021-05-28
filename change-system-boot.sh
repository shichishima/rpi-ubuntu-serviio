#!/bin/bash

system_boot_path=/Volumes/system-boot
/bin/echo -n "path to system-boot [${system_boot_path}]: "
read str
if [ ! -z ${str} ]; then
    system_boot_path=${str}
fi

hdmi_mode=4
/bin/echo -n "hdmi_mode [${hdmi_mode}]: "
read str
if [ ! -z ${str} ]; then
    hdmi_mode=${str}
fi

wifi_ssid=
/bin/echo -n "wifi_ssid [${wifi_ssid}]: "
read str
if [ ! -z ${str} ]; then
    wifi_ssid=${str}
fi

wifi_passwd=
/bin/echo -n "wifi_passwd [${wifi_passwd}]: "
read str
if [ ! -z ${str} ]; then
    wifi_passwd=${str}
fi


cat <<EOF

-----------------------------------------

system_boot_path: ${system_boot_path}
       hdmi_mode: ${hdmi_mode}
       wifi_ssid: ${wifi_ssid}
    wifi_passwod: ${wifi_passwd}

EOF
/bin/echo -n "OK? "
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
