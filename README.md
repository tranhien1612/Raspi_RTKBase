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


## Install str2str

```
git clone https://github.com/tomojitakasu/RTKLIB.git
cd RTKLIB/app/str2str/gcc
make

sudo cp str2str /usr/local/bin/
```


## Example

Read ubx data from serial and stream into tcp server:
```
str2str -in serial://ttyACM0:115200:8:n:1#ubx -out tcpsvr://:5016#rtcm3 -msg '1004,1005(10),1006,1008(10),1012,1019,1020,1033(10),1042,1045,1046,1077,1087,1097,1107,1127,1230' -p 47.0983869 -1.2655108 36.40
```
