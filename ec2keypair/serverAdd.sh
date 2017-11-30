#!/bin/sh 

# exit status check common function 
exitStatusCheck(){
    if [ $1 -ne 0 ]; then    
        echo "User selected Cancel."
        exit 1 
    fi
}

# input box host name 
host=$(whiptail --inputbox "Input Host Name?" 8 40 "swlee-dev"  --title "Host Name" 3>&1 1>&2 2>&3)
exitStatus=$?
exitStatusCheck $exitStatus

# if host name exist then end 
if [ -d ../data/servers/$host ]; then
    echo "Faild : It's server data already exists"
    exit 1
fi 

# input box ip address
ipaddress=$(whiptail --inputbox "Input IP Address?" 8 40 --title "IP Address" 3>&1 1>&2 2>&3)
exitStatus=$?
exitStatusCheck $exitStatus

# input box region 
region=$(whiptail --inputbox "Input Region?" 8 40 "Seoul"  --title "Region" 3>&1 1>&2 2>&3)
exitStatus=$?
exitStatusCheck $exitStatus

# save server info 
mkdir -p ../data/servers/$host 
echo "$host         $ipaddress          $region"  >> ../data/servers/$host/server.info 
echo "Success : It's completed adding server data"
echo "============================================="
cat ../data/servers/$host/server.info
exit 0









