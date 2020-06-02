#!/bin/bash

## Bash colors 
NOCOLOR='\033[0m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
LIGHTBLUE='\033[1;34m'
BOLDWHITE='\033[1;37m'
ORANGE='\033[0;33m'

banner () {
    echo -e "${ORANGE}

    _______                     ________        __
    |       |.-----.-----.-----.|  |  |  |.----.|  |_
    |   -   ||  _  |  -__|     ||  |  |  ||   _||   _|
    |_______||   __|_____|__|__||________||__|  |____|
            |__| W I R E L E S S   F R E E D O M
    -----------------------------------------------------
                    OPENWRT Utility tool
                        by quietwalker
                            v0.1
    -----------------------------------------------------
    ${NOCOLOR}"

}

upgrade_packages () {

    # function used to perform the packages upgrade
    perform_upgrade () {
        echo -e "${BOLDWHITE}[*] Installing upgrades...${LIGHTBLUE}"
        opkg list-upgradable | cut -f 1 -d ' ' | xargs opkg upgrade
        RESULT=$?
        if [ $RESULT -ne 0 ]; then 
            echo -e "${RED}[!] Something in the upgrade process failed! Please check ${NOCOLOR}"
        else
            echo -e "${GREEN}[*] Upgrade executed succesfully! ${NOCOLOR}"
        fi
    }

    echo -e "${BOLDWHITE}[*] Performing repository update${LIGHTBLUE}"
    opkg update 
    echo -e "${BOLDWHITE}[*] List of upgradable packages: ${NOCOLOR}"
    for pkg in $(opkg list-upgradable | awk '{print $1}');do echo -e ${LIGHTBLUE}$pkg ${NOCOLOR}; done
    while true; do
        echo -e "${BOLDWHITE}[*] Do you want to install the available packets upgrade? [y|n]"
        read answer
        case $answer in
            [Yy]* ) perform_upgrade; break;;
            [Nn]* ) echo -e "${BOLDWHITE}[!] Packege upgrade skipped${NOCOLOR}" exit;;
            * ) echo -e "${RED}[!] You can only enter 'y' or 'n' options!\n [!] Retry ${NOCOLOR}";;
        esac
    done

}

check_internet_connectivity (){
    echo -e "${BOLDWHITE}[*] Check if Internet is reachable... ${NOCOLOR}"
    ping -c 3 8.8.8.8 > /dev/null && echo -e "${GREEN}[*] Intenet connection is up${NOCOLOR}" || echo "${RED}[*] Intenet connection is down${NOCOLOR}"
}

check_dns_crypt (){

    echo -e "${BOLDWHITE}[*] Check if DNSCrypt processes are up and running... ${NOCOLOR}"
    pgrep dnscrypt > /dev/null
    RESULT=$? 
    if [ $RESULT -ne 0 ]; then 
        echo -e "${RED}[*] DNSCrypt processes not found on running process table. Trying to restart... ${NOCOLOR}"
        /etc/init.d/dnscrypt-proxy restart
        echo -e "${GREEN}[*] DNSCrypt processes restarted... ${NOCOLOR}"
        pgrep dnscrypt
        if [ $RESULT -eq 0 ]; then echo -e "${GREEN}[*] DNSCrypt processes are running fine ${NOCOLOR}"; else echo -e "${RED}[!] DNSCrypt processes not found on running process table${NOCOLOR}" && exit 1; fi 
    else 
        echo -e "${GREEN}[*] DNSCrypt processes OK ${NOCOLOR}"
    fi
    echo -e "${BOLDWHITE}[*] DNSCrypt used DNS resolver list... ${LIGHTBLUE}"
    egrep "resolver " /etc/config/dnscrypt-proxy | awk '{print $3}' | tr -d "'"
    echo -e "${NOCOLOR}"
    echo -e "${BOLDWHITE}[*] Performing www.google.com lookup using DNSCrypt... ${LIGHTBLUE}"
    nslookup www.google.com
    echo -e "${BOLDWHITE}[*] Performing www.google.com lookup using Google DNS... ${LIGHTBLUE}"
    nslookup www.google.com 8.8.8.8 
    echo -e "${NOCOLOR}"
}

sys_report () {
    echo -e "${BOLDWHITE}[*] System informations:"
    echo -e "${BOLDWHITE}[ -> ] Mounted filesystems ${LIGHTBLUE}"
    df -h 
    echo -e "${BOLDWHITE}[ -> ] Estimated file space usage informations ${LIGHTBLUE}"
    du -hs /*
    echo -e "${BOLDWHITE}[ -> ] Router uptime and Load Average ${LIGHTBLUE}"
    uptime 
    echo -e "${BOLDWHITE}[ -> ] OpenWrt Release informations ${LIGHTBLUE}"
    cat /etc/openwrt_release
    echo -e "${BOLDWHITE}[ -> ] Router processes currently running ${LIGHTBLUE}"
    top -b -n 1 | head -n 30 
    echo -e "${BOLDWHITE}[ -> ] Router date and hour ${LIGHTBLUE}"
    date
    echo -e "${BOLDWHITE}[ -> ] Router logs ${LIGHTBLUE}"
    logread | tail -n 20
    echo -e "${BOLDWHITE}[ -> ] Router kernel messages ${LIGHTBLUE}"
    dmesg | tail -n 10
}

banner 

check_internet_connectivity
check_dns_crypt
sys_report
upgrade_packages

echo -e "${BOLDWHITE} Bye Bye ${NOCOLOR}"