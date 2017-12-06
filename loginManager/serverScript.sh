#!/bin/bash

######################## common shell ########################

# variable
execution_date=`date`
dir_tmp=../data/tmp
dir_servers=../data/servers
dir_users=../data/users
dir_logs=../data/logs
aws_az=`curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone`
aws_region=${az::-1}

# exit status check common function
checkExitStatus(){
    if [ $1 -ne 0 ]; then
        echo "User selected Cancel."
        exit 1
    fi
}
appendLogs(){
	echo "$execution_date	$1	$2	$3	$4" >> $dir_logs/loginManager
}
checkrDuplicateByserver(){
	existFields=`cat $dir_servers/$1/$4 | cut -d '	' -f$2`
	for existField in ${existFields[@]}; do
		if [ "$existField" == "$3" ];then
			echo "Faild: $existField is exists"
			exit 1
		fi
	done
}
checkDuplicate(){
	existFields=`cat $dir_users/list | cut -d '	' -f$1`
	for existField in ${existFields[@]}; do
		if [ "$existField" == "$2" ];then
			echo "Faild: $existField is exists"
			exit 1
		fi
	done
}
getServerChecklist(){
	# read server list
	serverArray=`ls $dir_servers`
	for server in ${serverArray[@]}; do
			ipaddress=`cat $dir_servers/$server/server.info | awk '{print $2}'`
			region=`cat $dir_servers/$server/server.info | awk '{print $3}'`
			options=(${options[@]} $server "ip:"$ipaddress"_region:"$region off)
	done
	# select server
	selectedServerArray=$(whiptail --title "Server Info" --checklist "Choose host" $((${#options[@]}/3*2+4)) 60 $((${#options[@]}/3)) ${options[@]} 3>&1 1>&2 2>&3)
	echo ${selectedServerArray[@]}

}
getServerRadiolist(){
	# read server list
	serverArray=`ls $dir_servers`
	for server in ${serverArray[@]}; do
			ipaddress=`cat $dir_servers/$server/server.info | awk '{print $2}'`
			region=`cat $dir_servers/$server/server.info | awk '{print $3}'`
			options=(${options[@]} $server "ip:"$ipaddress"_region:"$region off)
	done
	# select server
	selectedServerItem=$(whiptail --title "Server Info" --radiolist "Choose a host" $((${#options[@]}/3*2+4)) 60 $((${#options[@]}/3)) ${options[@]} 3>&1 1>&2 2>&3)
	echo $selectedServerItem
}

getUserChecklist(){
	# read user list
	while read name email loginUser authkey date; do
		options=(${options[@]} $name "email:$email" off)
	done < $dir_users/list

	# select user
	selectedUserArray=$(whiptail --title "User Info" --checklist "Choose user" $((${#options[@]}/3*2+4)) 60 $((${#options[@]}/3)) ${options[@]} 3>&1 1>&2 2>&3)
	echo ${selectedUserArray[@]}
}

getUserChecklistByHost(){
	# read user list
	while read name keypair; do
		options=(${options[@]} $name "keypair:$keypair" off)
	done < $dir_servers/$1/user.info

	# select user
	selectedUserArray=$(whiptail --title "User Info" --checklist "Choose user" $((${#options[@]}/3*2+4)) 60 $((${#options[@]}/3)) ${options[@]} 3>&1 1>&2 2>&3)
	echo ${selectedUserArray[@]}
}
getUserfield(){
	keyword=`cat $dir_users/list | cut -d '	' -f$1`
 	if [ "$keyword" == "$2" ];then
		userfield=`cat $dir_users/list | cut -d '	' -f$3`
	 	echo $userfield
 	fi
}
######################## excution shell ########################
checkEmptyServers(){
	if [ ! "$(ls -A $dir_servers)" ];then
		echo "No server. First need to command $0 add"
		exit 1
	fi
}
serverUpdate(){
	# read server list
	local selectServer=$(getServerRadiolist)

	# if not selected
	if [ -z "$selectServer" ]; then
	    echo "Select one or more host."
	    exit 1
	fi

	# input box ip address for re-add
	changedServer=$(whiptail --inputbox "Change Host name?" 8 40 "$selectServer" --title "New Host Name" 3>&1 1>&2 2>&3)
	exitStatus=$?
	checkExitStatus $exitStatus
	#checkrDuplicateByserver $selectServer 1 $changedServer server.info

	# input box ip address for re-add
	selectIpaddress=`cat $dir_servers/$selectServer/server.info | awk '{print $2}'`
	changedIpaddress=$(whiptail --inputbox "Change IP Address?" 8 40 "$selectIpaddress" --title "New IP Address" 3>&1 1>&2 2>&3)
	exitStatus=$?
	checkExitStatus $exitStatus

	# input box region for re-add
	selectRegion=`cat $dir_servers/$selectServer/server.info | awk '{print $3}'`
	changedRegion=$(whiptail --inputbox "Change Region?" 8 40 "$selectRegion"  --title "New Region" 3>&1 1>&2 2>&3)
	exitStatus=$?
	checkExitStatus $exitStatus

	# input box key pair
	selectKeypair=`cat $dir_servers/$selectServer/server.info | awk '{print $4}'`
	changedKeypair=$(whiptail --inputbox "Change Pem Keyname?" 8 40 "$selectKeypair" --title "Key pair" 3>&1 1>&2 2>&3)
	exitStatus=$?
	checkExitStatus $exitStatus

	# delete old server data
	rm $dir_servers/$selectServer/server.info

	# re-add new server data
	echo "Update the server data..."
	if [ $selectServer != $changedServer ];then
		mv $dir_servers/$selectServer $dir_servers/$changedServer
	fi
	echo "$changedServer	$changedIpaddress	$changedRegion	$changedKeypair"  >> $dir_servers/$changedServer/server.info
	# if user has server info, update.
	loginUserArray=`sudo ls /home/`
	for loginUser in ${loginUserArray[@]}; do
		if [ $loginUser != "ec2-user" ]; then
			sudo cat /home/$loginUser/$loginUser.list | grep $selectServer
			if [ $? -eq 0 ]; then
				email=`cat $dir_users/list | grep $loginUser | awk '{print $2}'`
				sudo sed -i "s/$selectServer	ec2-user	$selectIpaddress	$email.pem	$selectRegion/$changedServer	ec2-user	$changedIpaddress	$email.pem	$changedRegion/g" /home/$loginUser/$loginUser.list
			fi
		fi
	done

}


# add server process
serverAdd(){

	# input box server name
	server=$(whiptail --inputbox "Input Host Name" 8 40 --title "Host Name" 3>&1 1>&2 2>&3)
	exitStatus=$?
	checkExitStatus $exitStatus

	if [ -z "$server" ];then
		echo "Faild: No space"
		exit 1
	fi

	# if server name exist then end
	if [ -d $dir_servers/$server ]; then
	    echo "Faild : It's server data already exists"
	    exit 1
	fi

	# input box ip address
	ipaddress=$(whiptail --inputbox "Input IP Address?" 8 40 --title "IP Address" 3>&1 1>&2 2>&3)
	exitStatus=$?
	checkExitStatus $exitStatus

	# input box region
	region=$(whiptail --inputbox "Input Region?" 8 40 "Seoul"  --title "Region" 3>&1 1>&2 2>&3)
	exitStatus=$?
	checkExitStatus $exitStatus

	# input box key pair
	keypair=$(whiptail --inputbox "Input Pem Keyname" 8 40 --title "Key pair" 3>&1 1>&2 2>&3)
	exitStatus=$?
	checkExitStatus $exitStatus

	# set
	mkdir -p $dir_servers/$server
	touch $dir_servers/$server/user.info

	# save server info
	echo "$server	$ipaddress	$region	$keypair"  >> $dir_servers/$server/server.info
	appendLogs "createServerInfo"	$server	$ipaddress	$keypair
}


# delete server process
serverDelete(){
	# read server list
	serverArray=`ls $dir_servers/`
	for server in ${serverArray[@]}; do
	    ipaddress=`cat $dir_servers/$server/server.info | awk '{print $2}'`
	    region=`cat $dir_servers/$server/server.info | awk '{print $3}'`
	    options=(${options[@]} $server "ip:"$ipaddress"_region:"$region off)
	done

	# select server
	selectedServerArray=$(whiptail --title "Server Info" --checklist "Choose a server to adding user data" $((${#options[@]}/3*2+4)) 60 $((${#options[@]}/3)) ${options[@]} 3>&1 1>&2 2>&3)
	exitStatus=$?
	checkExitStatus $exitStatus

	# if not selected
	if [ -z "${selectedServerArray[@]}" ]; then
	    echo "Select one or more host."
	    exit 1
	fi

	# delete server data
	for selectedServerItem in ${selectedServerArray[@]};do
	    strServer=`sed -e 's/^"//' -e 's/"$//' <<<"$selectedServerItem"`
	    rm -rf $dir_servers/$strServer
	    echo "Success: It's completed deleting \"$strServer\" server data"
			appendLogs "deleteServerInfo" $strServer
	done
}
serverInfo(){
	ls $dir_servers
}


case "$1" in
	add)
		serverAdd
		;;
	info)
		checkEmptyServers
		serverInfo
		;;
	update)
		checkEmptyServers
		serverUpdate
		;;
	delete)
		checkEmptyServers
		serverDelete
		;;
	*)
		echo $"Usage: $0 {add|info|update|delete}"
		exit 1
		;;
esac
exit $?
