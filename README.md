# Download and install AmneziaWG on Ubiquiti edge devices
***Warning:*** *This script attempts to preserve your running configuration, however you should have a backup of your configuration before running this script.*
 
This script will reference [coffeegrind123/amneziawg-vyatta-ubnt](https://github.com/coffeegrind123/amneziawg-vyatta-ubnt) repo for AmneziaWG releases. It will download, install, and setup the package to install post firmware upgrade. Rebooting the device is **not** required after running this script as long as the script did not generate any errors. Grab the script by running the following commands from the web CLI or SSH.
```
cd /config/scripts
curl -LO --silent https://github.com/coffeegrind123/ubnt_get_amneziawg/raw/master/get_amneziawg.sh
chmod +x get_amneziawg.sh
```
***Note:*** *Best practice is to save scripts into *`/config/scripts`* directory.*

## Supported Devices
This script supports the following Ubiquiti devices with automatic firmware version detection:
- **EdgeRouter X, EdgeRouter X SFP** (e50)
- **EdgeRouter Lite, EdgeRouter PoE** (e100) 
- **EdgeRouter 8, EdgeRouter Pro** (e200)
- **EdgeRouter 4, EdgeRouter 6P, EdgeRouter 12** (e300)
- **EdgeRouter Infinity** (e1000)
- **UniFi Security Gateway** (ugw3)
- **UniFi Security Gateway Pro 4** (ugw4)
- **UniFi Security Gateway XG 8** (ugwxg)

The script automatically detects your EdgeOS version (v1 or v2) and downloads the appropriate package.

## Usage
To download and install the latest release of AmneziaWG, run the following command.
```
./get_amneziawg.sh
```
To download and install a specific release of AmneziaWG, run the following command with the desired release as a parameter.
```
./get_amneziawg.sh v1.0.20241112-1.0.20250706
```
## Log
The script writes a log to `/tmp/get_amneziawg.log`. This log file will be removed after reboot of the device.
## Automation
To automatically run this script once per week, you can run the following commands from an EdgeMAX device.
```
configure
set system task-scheduler task get_amneziawg executable path /config/scripts/get_amneziawg.sh
set system task-scheduler task get_amneziawg interval 7d
commit
save
exit
```
## Uninstall
To uninstall AmneziaWG, run the following command.
```
sg vyattacfg "$(curl -sL https://github.com/coffeegrind123/ubnt_get_amneziawg/raw/master/uninstall_amneziawg.sh)"
```

## What is AmneziaWG?
AmneziaWG is an enhanced version of WireGuard that provides additional obfuscation capabilities to help bypass deep packet inspection (DPI) and network censorship. It maintains full compatibility with standard WireGuard while adding features like:
- Traffic obfuscation to avoid detection
- Junk packet injection
- Custom packet headers
- Enhanced stealth capabilities

For more information, visit the [AmneziaWG repository](https://github.com/coffeegrind123/amneziawg-vyatta-ubnt).
