# Config Raspi for AP mode


## Install bulleye Image for Raspi
Example: Using Raspbery Pi Imager to flash image (Raspberry Pi OS - 64Bit) into SDCard

## Install lib for setup AP mode

### Getting started
To create an access point, we’ll need DNSMasq and HostAPD. Install all the required software in one go with this command:
```
sudo apt install dnsmasq hostapd
```

Since the configuration files are not ready yet, we need to stop the new software from running:
```
sudo systemctl stop dnsmasq
sudo systemctl stop hostapd
```

### Configure a static IP

To configure the static IP address, edit the dhcpcd configuration file with:
```
sudo nano /etc/dhcpcd.conf
```

Go to the end of the file and edit it so that it looks like the following:
```
interface wlan0
    static ip_address=192.168.10.1/24
    nohook wpa_supplicant
```

Now restart the dhcpcd daemon and set up the new wlan0 configuration:
```
sudo service dhcpcd restart
```

### Configure the DHCP server

The DHCP service is provided by dnsmasq. Let’s backup the old configuration file and then create a new one:
```
sudo mv /etc/dnsmasq.conf /etc/dnsmasq.conf.orig
sudo nano /etc/dnsmasq.conf
```

Type the following information into the dnsmasq configuration file and save it:
```
interface=wlan0
dhcp-range=192.168.10.2,192.168.10.254,255.255.255.0,24h
```

Now start dnsmasq to use the updated configuration:
```
sudo systemctl start dnsmasq
```

### Configure the access point host software
Now it is time to configure the access point software:
```
sudo nano /etc/hostapd/hostapd.conf
```

Add the below information to the configuration file:
```
country_code=US
interface=wlan0
ssid=YOURSSID
channel=9
auth_algs=1
wpa=2
wpa_passphrase=YOURPWD
wpa_key_mgmt=WPA-PSK
wpa_pairwise=TKIP CCMP
rsn_pairwise=CCMP
```

Make sure to change the `ssid` and `wpa_passphrase`. We now need to tell the system where to find this configuration file. Open the hostapd file:
```
sudo nano /etc/default/hostapd
```

Find the line with #DAEMON_CONF, and replace it with this:
```
DAEMON_CONF="/etc/hostapd/hostapd.conf"
```

### Start up the wireless access point
Run the following commands to enable and start hostapd:
```
sudo systemctl unmask hostapd
sudo systemctl enable hostapd
sudo systemctl start hostapd
```

You may want devices connected to your wireless access point to access the main network and from there the internet. To do so, we need to set up routing and IP masquerading on the Raspberry Pi. We do this by editing the sysctl.conf file:
```
sudo nano /etc/sysctl.conf
```
And uncomment the following line:
```
net.ipv4.ip_forward=1
```

### Stop the access point
First stop the hostadp service:
```
sudo systemctl stop hostap
```

Edit the dhcpcd.conf file:
```
sudo nano /etc/dhcpcd.conf
```

and comment out the lines related to the static IP address. Now reboot
```
sudo reboot
```



