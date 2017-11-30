#!/bin/bash 

# exit status check common function 
exitStatusCheck(){
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

# select server
selectHosts=$(whiptail --title "Server Info" --checklist "Choose a host to adding user data" $((${#options[@]}/3*2+4)) 60 $((${#options[@]}/3)) ${options[@]} 3>&1 1>&2 2>&3)
exitStatus=$?
exitStatusCheck $exitStatus

# if not selected 
if [ -z "${selectHosts[@]}" ]; then
    echo "Select one or more host."
    exit 1 
fi     

# delete server data
for selectHost in ${selectHosts[@]};do
    editHost=`sed -e 's/^"//' -e 's/"$//' <<<"$selectHost"`
    rm -rf ../data/servers/$editHost
    echo "Success: It's completed deleting \"$editHost\" server data"
done
exit 0 