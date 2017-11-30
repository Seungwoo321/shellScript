#!/bin/bash 

# exit status check common function 
exitStatusCheck() {
    if [ $1 -ne 0 ]; then   
        echo "User selected Cancel."
        exit 1 
    fi
}

# read server list 
hosts=`ls ../data/servers/`
for host in ${hosts[@]}; do
    ipaddress=`cat ../data/servers/$host/server.info | awk '{print $2}'`
    region=`cat ../data/servers/$host/server.info | awk '{print $3}'`
    options=(${options[@]} $host "ip:"$ipaddress"_region:"$region off)
done 

# select server for update 
selectHost=$(whiptail --title "Server Info" --radiolist "Choose a host to adding user data" $((${#options[@]}/3*2+4)) 60 $((${#options[@]}/3)) ${options[@]} 3>&1 1>&2 2>&3)
exitStatus=$?
exitStatusCheck $exitStatus

# if not selected 
if [ -z $selectHost ]; then 
    echo "Select one or more host."
    exit 1 
fi 

# input box ip address for re-add 
selectIpaddress=`cat ../data/servers/$selectHost/server.info | awk '{print $2}'`
changedIpaddress=$(whiptail --inputbox "Change IP Address?" 8 40 "$selectIpaddress" --title "IP Address" 3>&1 1>&2 2>&3)
exitStatus=$?
exitStatusCheck $exitStatus

# input box region for re-add
selectRegion=`cat ../data/servers/$selectHost/server.info | awk '{print $3}'`
changedRegion=$(whiptail --inputbox "Change Region?" 8 40 "$selectRegion"  --title "Region" 3>&1 1>&2 2>&3)
exitStatus=$?
exitStatusCheck $exitStatus

# delete old server data 
rm ../data/servers/$selectHost/server.info 

# re-add new server data 
echo "Re-add the server data..."
echo "$selectHost         $changedIpaddress          $changedRegion"  >> ../data/servers/$selectHost/server.info 

# Complate Message 
echo "Success : It's completed updating server data"
echo "============================================="
cat ../data/servers/$selectHost/server.info
exit 0


