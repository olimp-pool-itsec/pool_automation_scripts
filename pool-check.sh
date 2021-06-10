#!/usr/bin/env bash
################################
###                          ###
###     OLIMP stakepool      ###
###                          ###
###       olympus.rest       ###
###                          ###
################################
VERSION="v0.0.1"

C=$(printf '\033')
WHITE="${C}[1;37m"
RED="${C}[1;31m"
GREEN="${C}[1;32m"
YELLOW="${C}[1;33m"
BLUE="${C}[1;34m"
MAGNETA="${C}[1;35m"
LG="${C}[1;37m" #LightGray
DG="${C}[1;90m" #DarkGray
NC="${C}[0m"
UNDERLINED="${C}[5m"
ITALIC="${C}[3m"
SCORE=15
#######
if ! [ $(id -u) = 0 ]; then
echo -e "${RED}You must be root to run this script.${NC}"
exit 1
fi
#######



#check sudo vuln
test_sudo=$(sudo -V | grep "Sudo ver" | grep "1\.[01234567]\.[0-9]\+\|1\.8\.1[0-9]\*\|1\.8\.2[01234567]")
echo -ne "${WHITE}Checking sudo version is vurnable.. ${NC}"
if [ -z "$test_sudo" ]

then
    echo 'OK'
else
    echo -e "${LG}[${NC}${RED}!${NC}${LG}]${NC} NOT OK"
    SCORE=$[SCORE-1]
    echo $(sudo -V | grep "Sudo ver" | grep "1\.[01234567]\.[0-9]\+\|1\.8\.1[0-9]\*\|1\.8\.2[01234567]")
fi


#check dmesg signiature verification failed
echo -ne "${WHITE}Checking if dmesg signiature verification failed.. ${NC}"
test_dmesg=$(dmesg 2>/dev/null | grep "signature")
if [ -z "$test_dmesg" ]
then
    echo 'OK'
else
    echo -e "${LG}[${NC}${RED}!${NC}${LG}]${NC} NOT OK"
    SCORE=$[SCORE-1]
    echo $(dmesg 2>/dev/null | grep "signature")
fi


###
###SSHD CONFIGURATION CHECK
###

echo -e "${WHITE}Checking SSHD configuration...${NC}"
if grep -Eq 'Port 22' /etc/ssh/sshd_config; then
    echo -e "${LG}[${NC}${RED}!${NC}${LG}]${NC}${RED} Port should not be set to 22${NC}";
    SCORE=$[SCORE-1]
fi
if grep -Eq 'PasswordAuthentication yes' /etc/ssh/sshd_config; then
    echo -e "${LG}[${NC}${RED}!${NC}${LG}]${NC}${RED} password authentication should not be allowed.${NC}";
    SCORE=$[SCORE-1]
fi
if grep -Eq 'ChallengeResponseAuthentication yes' /etc/ssh/sshd_config; then
    echo  -e "${LG}[${NC}${RED}!${NC}${LG}]${NC}${RED} ChallengeResponseAuthentication should not be allowed.${NC}";
    SCORE=$[SCORE-1]
fi
if grep -Eq 'PermitRootLogin prohibit-pasword' /etc/ssh/sshd_config; then
    echo  -e "${LG}[${NC}${RED}!${NC}${LG}]${NC}${RED} Root should not be able to login directly.${NC}";
    SCORE=$[SCORE-1]
fi
if grep -Eq 'PermitRootLogin yes' /etc/ssh/sshd_config; then
    echo  -e "${LG}[${NC}${RED}!${NC}${LG}]${NC}${RED} Root should not be able to login directly.${NC}";
    SCORE=$[SCORE-1]
fi
if grep -Eq 'X11Forwarding yes' /etc/ssh/sshd_config; then
    echo  -e "${LG}[${NC}${RED}!${NC}${LG}]${NC}${RED} X11Forwarding - You don't need that..${NC}";
    SCORE=$[SCORE-1]
fi
if grep -Eq 'PubkeyAuthentication yes' /etc/ssh/sshd_config; then
    echo  -e "${LG}[${NC}${GREEN}!${NC}${LG}]${NC}${GREEN} PubkeyAuthentication yes${NC}";
fi

###
###USER CHECK
###

echo -e "${WHITE}Checking users...${NC}"
###List all users in sudo group
echo -ne "${BLUE}users with sudo access: ${NC}"
echo -e "${GREEN}"$(grep '^sudo:.*$' /etc/group | cut -d: -f4)"${NC}"
###if more then 1 ?   SCORE=SCORE-1??

###List all users with some kind of shell
echo -ne "${BLUE}users that can login to shell: ${NC}"
echo -e "${GREEN}" $(cat /etc/passwd | grep "sh$" | cut -f 1 -d  ":" | tr "\n" " ") "${NC}"
####List superusers
echo -e "${BLUE}Superusers: ${NC}${GREEN}" $(awk -F: '($3 == "0") {print}' /etc/passwd  | cut -f 1 -d  ":" | tr "\n" " ")"${NC}"
###if more then 1   SCORE=SCORE-2


###
###Network check
###

echo -e "${WHITE}Checking network...${NC}"

###IPV6 
echo -ne "${BLUE}Checking for any ipv6 connections...${NC}"

cmd='lsof -a -i6'
if [ -z $lsof -a -i6_ ]
then
    echo -e "${GREEN}OK${NC}"
else
    echo -e "${RED}NOT OK${NC} ${LG}[${NC}${RED}!${NC}${LG}]${NC}"
    SCORE=$[SCORE-1]
fi

#ipv6
echo -ne "${BLUE}Checking if IPv6 is supported...${NC} "
if grep -q 0 "/proc/sys/net/ipv6/conf/all/disable_ipv6" ; then
    echo -e "${RED}ipv6 enabled${NC} ${LG}[${NC}${RED}!${NC}${LG}]${NC}  | check our page for recipe" 
    SCORE=$[SCORE-1]
else
    echo -e "${GREEN}ipv6 disbled${NC}"
fi



#Firewall
echo -ne "${BLUE}Checking if UFW is installed...${NC} "
test_ufw=$(which ufw)
if [ -z "$test_ufw" ] ; then
    echo -e "${RED}ufw not found${NC} ${LG}[${NC}${RED}!${NC}${LG}]${NC} | sudo apt update && sudo apt install ufw -y"
    SCORE=$[SCORE-1]
else
    echo -e "${GREEN}OK${NC}"
    ufw_status=true
fi

if [ "$ufw_status" = true ] ; then
    echo -ne "${BLUE}Checking if UFW is active...${NC} "
    if [ $(ufw status | head -n 1 | cut -f 2 -d  ":" | tr "\n" " " ) = 'active' ];
    then
    echo -e "${GREEN}OK${NC}"
    else
        echo -e "${LG}[${NC}${RED}!${NC}${LG}]${NC} ${RED}NOT OK${NC} | check our page for recipe"
        SCORE=$[SCORE-1]
    fi
fi


#Node-user
echo -ne "${BLUE}Checking what user run cardano-node...${NC} "
if [ $(cat /etc/systemd/system/cnode.service | grep User | cut -f 2 -d  "=") = 'root' ];
then
    echo -e "${RED} CARDANO NODE RUN AS ROOT ${NC} ${LG}[${NC}${RED}!${NC}${LG}]${NC}"
    SCORE=$[SCORE-1]
else
echo -e "${GREEN}OK${NC}" 
fi



echo -e "Need help? Check our blog ${GREEN}->${NC} ${WHITE}https://olympus.rest/blog/basic-node-security/${NC}"
awk -v i=$SCORE 'BEGIN { OFS="₳"; $i="₳"; print }'
echo -e "${YELLOW}SCORE${NC} ${WHITE}[${NC}${GREEN}${SCORE}${NC}/${GREEN}15${NC}${WHITE}]${NC}"
echo -e "${WHITE}things not cover${NC} check https://book.hacktricks.xyz/linux-unix/linux-privilege-escalation-checklist"
