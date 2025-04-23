#!/bin/bash

if [ "$EUID" -ne 0 ]; then
    echo "Error: This script must be run as root or with sudo privileges."
    echo "Usage: sudo ./autoAP.sh"
    exit 1
fi

function askyn() {
    local ans
    echo -n "$1" '[y/n]? ' ; read $2 ans
    case "$ans" in
        y*|Y*) return 0 ;;
        *) return 1 ;;
    esac
}

echo ""
echo -n "SSID for Access Point mode: "
apssid=$(read ans; echo $ans)
echo -n "Password for Access Point mode: "
appsk=$(read ans; echo $ans)
echo -n "IPV4 address for Access Point mode [192.168.10.1]: "
apip=$(read ans; echo $ans)

if [[ -z "$apip" ]]; then
    apip="192.168.10.1"
fi
if ! [[ "$apip" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "Error: Invalid IP address format."
    exit 1
fi

IFS='.' read -r ip1 ip2 ip3 ip4 <<< "$apip"
start_ip="${ip1}.${ip2}.${ip3}.2"
end_ip="${ip1}.${ip2}.${ip3}.254"

echo ""
echo "        autoAP Configuration"
echo " Access Point SSID:     $apssid"
echo " Access Point password: $appsk"
echo " Access Point IP addr:  $apip"
echo ""

if ! askyn "Are you ready to proceed"
then
    echo ""
    echo "% No changes have been made to your system"
    exit 0
fi

echo "Install lib......"
sudo apt-get update
sudo apt install dnsmasq hostapd -y

echo "Disable dnsmasq and hostapd"
sudo systemctl stop dnsmasq
sudo systemctl stop hostapd

echo "Edit /etc/dhcpcd.conf"
DHCPCD_FILE="/etc/dnsmasq.conf"
echo "interface wlan0" >> "$DHCPCD_FILE"
echo "static ip_address=$apip/24" >> "$DHCPCD_FILE"
echo "nohook wpa_supplicant" >> "$DHCPCD_FILE"

echo "Edit /etc/dnsmasq.conf"
DNSMASQ_FILE="/etc/dnsmasq.conf"
sudo mv /etc/dnsmasq.conf /etc/dnsmasq.conf.orig
cat <<EOF >> "$DNSMASQ_FILE"
interface=wlan0
dhcp-range=$start_ip,$end_ip,255.255.255.0,24h
EOF

sudo systemctl reload dnsmasq

echo "Create /etc/hostapd/hostapd.conf"
HOSTAPD_FILE="/etc/hostapd/hostapd.conf"
cat <<EOF >> "$HOSTAPD_FILE"
country_code=US
interface=wlan0
ssid=$apssid
channel=9
auth_algs=1
wpa=2
wpa_passphrase=$appsk
wpa_key_mgmt=WPA-PSK
wpa_pairwise=TKIP CCMP
rsn_pairwise=CCMP
EOF

HOSTAPD_CONF_FILE="/etc/default/hostapd"
echo "DAEMON_CONF=\"/etc/hostapd/hostapd.conf" >> "$HOSTAPD_CONF_FILE"

sudo systemctl unmask hostapd
sudo systemctl enable hostapd
sudo systemctl start hostapd
sudo reboot
