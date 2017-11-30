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

# input box user name 
inputUserName=$(whiptail --inputbox "Input User Name?" 8 40 "홍길동"  --title "User Name" 3>&1 1>&2 2>&3)
exitStatus=$?
exitStatusCheck $exitStatus

# input box user email 
inputUserEmail=$(whiptail --inputbox "Input User Email?" 8 40 "email" --title "User Email" 3>&1 1>&2 2>&3)
exitStatus=$?
exitStatusCheck $exitStatus

# save user info for server 
for selectHost in ${selectHosts[@]};do
    editHost=`sed -e 's/^"//' -e 's/"$//' <<<"$selectHost"`
    touch ../data/servers/${editHost}/user.info
    existUsers=`cat ../data/servers/${editHost}/user.info | awk '{print $1}'`
    isUser=false
    for existUser in $existUsers; do
        if [ "$existUser" == "$inputUserName" ]; then
            isUser=true
        fi
    done 
    if [ $isUser == false ]; then
        echo "Success: User data has been added on $selectHost host. "
        echo "$inputUserName         $inputUserEmail" >> ../data/servers/${editHost}/user.info
        echo "======================================"
        echo ${editHost}
        cat ../data/servers/${editHost}/user.info
        echo "======================================"
    else 
        echo "Faild: $selectHost host has the same username."
    fi 
done


exit 0





