# pwnWifi

pwnWifi is a bash script designed to automate Wi-Fi penetration testing using various attack modes. The script leverages tools like `aircrack-ng`, `macchanger`, `hcxdumptool`, and `hashcat` to perform handshake and PKMID attacks on Wi-Fi networks.

## Features

- **Handshake Attack**: Captures WPA/WPA2 handshakes and attempts to crack them using a wordlist.
- **PKMID Attack**: Performs a client-less attack to capture PMKID hashes and attempts to crack them.

## Prerequisites

Before running the script, ensure you have the following tools installed:

- `aircrack-ng`
- `macchanger`
- `xterm`
- `hcxdumptool`
- `hashcat`
- `rockyou.txt` wordlist (commonly found in `/usr/share/wordlists/`)

## Installation

To install the necessary dependencies, you can use the following commands:

```bash
sudo apt-get update
sudo apt-get install aircrack-ng macchanger xterm hcxdumptool hashcat -y
```

Ensure you have the `rockyou.txt` wordlist:

```bash
sudo apt-get install wordlists
```

## Usage

Run the script with root privileges:

```bash
sudo ./pwnWifi.sh -a [Attack Mode] -n [Network Interface]
```

### Parameters

- `-a`: Attack mode (`Handshake` or `PKMID`)
- `-n`: Network interface name (e.g., `wlan0`)

### Example

```bash
sudo ./pwnWifi.sh -a Handshake -n wlan0
```

## Help

To display the help panel, use the `-h` option:

```bash
sudo ./pwnWifi.sh -h
```

## Disclaimer

This script is intended for educational purposes only. Unauthorized use of this script to attack networks without permission is illegal and unethical. Use responsibly.

## Author

- [Osman Tunahan ARIKAN](https://github.com/OsmanTunahan) | Cyber Security Expert