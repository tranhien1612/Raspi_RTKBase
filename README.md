# Raspi_RTKBase

## [Download Raspi Image](https://github.com/RaspAP/raspap-webgui)

```
wget https://github.com/RaspAP/raspap-webgui/releases/download/3.3.2/raspap-bookworm-arm64-lite-3.3.2.img.zip
```

Using tool to flash image into SDCard. After booting process is complete, Connect to wifi of raspi:
```
SSID: RaspAP
Password: ChangeMe
```

## Install RTKBase

SSH into raspi and run command:
```
cd ~
wget https://raw.githubusercontent.com/Stefal/rtkbase/master/tools/install.sh -O install.sh
chmod +x install.sh
sudo ./install.sh --all release
```

Open a web browser to `http://ip_of_your_sbc` (the script will try to show you this ip address). Default password is admin.

Config Serial and NTRIPCaster.
