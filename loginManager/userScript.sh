#!/bin/bash

######################## common shell ########################

# variable
execution_date=`date`
dir_tmp=../data/tmp
dir_servers=../data/servers
dir_users=../data/users
dir_logs=../data/logs
aws_az=`curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone`
aws_region=${aws_az::-1}

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

# login user setting function
createLoginUser(){
	sudo adduser $1
	sudo -u $1 mkdir /home/$1/.ssh
	sudo -u $1 chmod 700 /home/$1/.ssh
	sudo -u $1 touch /home/$1/.ssh/authorized_keys
	sudo -u $1 chmod 600 /home/$1/.ssh/authorized_keys
	sudo -u $1 mkdir /home/$1/.key
	sudo -u $1 chmod 700 /home/$1/.key
	sudo -u $1 touch /home/$1/$1.list
	sudo cp conn.sh /home/$1/
	sudo chown $1.$1 /home/$1/conn.sh

}

# create key pair
createKeypair(){
	aws ec2 create-key-pair --key-name $1 --region $aws_region --query 'KeyMaterial' --output text > $dir_tmp/$1.pem
	chmod 400 $dir_tmp/$1.pem
}
# delte keypair
deleteKeypair(){
	aws ec2 delete-key-pair --key-name $1 --region $aws_region
}

# add user process
userAdd(){
	# input box user name
	inputUserName=$(whiptail --inputbox "Input User Name?" 8 40 "홍길동"  --title "User Name" 3>&1 1>&2 2>&3)
	exitStatus=$?
	checkExitStatus $exitStatus
	checkDuplicate 1 $inputUserName

	# input box user email
	inputUserEmail=$(whiptail --inputbox "Input User Email?" 8 40 "hong@email.com" --title "User Email" 3>&1 1>&2 2>&3)
	exitStatus=$?
	checkExitStatus $exitStatus
	checkDuplicate 2 $inputUserEmail

	# input box bastion server login user
	inputLoginUser=$(whiptail --inputbox "Input Login User?" 8 40 "hong"  --title "Login User" 3>&1 1>&2 2>&3)
	exitStatus=$?
	checkExitStatus $exitStatus
	checkDuplicate 3 $inputLoginUser

	# loging user add
	createLoginUser $inputLoginUser
	appendLogs "createLoginUser" $inputUserName $inputLoginUser

	# create new key pair
	createKeypair $inputUserEmail
	authkey=`ssh-keygen -lf $dir_tmp/$inputUserEmail.pem | cut -d ' ' -f2`
	appendLogs "createKeypair" $inputUserEmail.pem $authkey

	# register new keypair
	pubkey=`ssh-keygen -y -f $dir_tmp/$inputUserEmail.pem`
	echo $pubkey $inputUserEmail >> $dir_tmp/authorized_keys

	# setting bastion server keypair
	sudo mv $dir_tmp/$inputUserEmail.pem /home/$inputLoginUser/.key/
	sudo mv $dir_tmp/authorized_keys /home/$inputLoginUser/.ssh/
	sudo chown -R $inputLoginUser.$inputLoginUser /home/$inputLoginUser

	# add user list
	echo "$inputUserName	$inputUserEmail	$inputLoginUser	$authkey	$execution_date" >> $dir_users/list
}
# delete user process
userDelete(){
	# read user list
	local selectedUserArray=$(getUserChecklist)
	# if not selected
	exitStatus=$?
	checkExitStatus $exitStatus
	if [ -z "${selectedUserArray[@]}" ]; then
	    echo "Select one or more host."
	    exit 1
	fi

	# delete process
	for selectedUserItem in ${selectedUserArray[@]};do
		userStr=`sed -e 's/^"//' -e 's/"$//' <<<"$selectedUserItem"`

		# remove user info by host
		serverArray=`ls $dir_servers/`
		for server in ${serverArray[@]}; do
				sed -i /$userStr/d $dir_servers/$server/user.info
		done

		while read name email loginUser authkey date; do
			if [ "$userStr" == "$name" ]; then
				# delete keypair
				deleteKeypair $email
				# delete home directory
				sudo userdel -r $loginUser
				# append log
				appendLogs "deleteKeypair" $email.pem $authkey
			fi
		done < $dir_users/list

		# delete user from list
		sed -i /$userStr/d $dir_users/list

	done

}

# user register process
userRegister(){
	# select server
	local selectedServerArray=$(getServerChecklist)
	# if not selected
	exitStatus=$?
	checkExitStatus $exitStatus
	if [ -z "${selectedServerArray[@]}" ]; then
	    echo "Select one or more host."
	    exit 1
	fi

	# select user
	local selectedUserArray=$(getUserChecklist)
	# if not selected
	exitStatus=$?
	checkExitStatus $exitStatus
	if [ -z "${selectedUserArray[@]}" ]; then
	    echo "Select one or more host."
	    exit 1
	fi

	# register process
	for selectedServerItem in ${selectedServerArray};do
		strServer=`sed -e 's/^"//' -e 's/"$//' <<<"$selectedServerItem"`
		rm $dir_servers/$strServer/user.info
		touch $dir_servers/$strServer/user.info

		# authorized_keys create
		oldKeypair=`cat $dir_servers/$strServer/server.info | cut -d '	' -f4`
		oldPubkey=`ssh-keygen -y -f ~/.key/$oldKeypair.pem`
		echo $oldPubkey $oldKeypair >> $dir_tmp/$strServer.authorized_keys

		# variable
		ipaddress=`cat $dir_servers/$strServer/server.info | cut -d '	' -f2`
		region=`cat $dir_servers/$strServer/server.info | cut -d '	' -f3`

		for selectedUserItem in ${selectedUserArray[@]};do
			strUser=`sed -e 's/^"//' -e 's/"$//' <<<"$selectedUserItem"`

			# server's user info update
			#checkrDuplicateByserver $strServer 1 $strUser user.info
			while read name email loginUser authkey date; do
				if [ "$strUser" == "$name" ]; then
					# user info update by host
					echo "$name	$email" >> $dir_servers/$strServer/user.info

					# user server list update
					sudo cat /home/$loginUser/$loginUser.list | grep $strServer
					if [ $? -eq 1 ]; then
						sudo mv /home/$loginUser/$loginUser.list $dir_tmp/$loginUser.list
						sudo chown ec2-user.ec2-user $dir_tmp/$loginUser.list
						echo "$strServer	ec2-user	$ipaddress	$email.pem	$region" >> $dir_tmp/$loginUser.list
						sudo mv $dir_tmp/$loginUser.list /home/$loginUser/$loginUser.list
						sudo chown $loginUser.$loginUser /home/$loginUser/$loginUser.list
					fi

					# authorized_keys update
					newKeypair=$email
					newPubkey=`sudo ssh-keygen -y -f /home/$loginUser/.key/$newKeypair.pem`
					echo $newPubkey $newKeypair >> $dir_tmp/$strServer.authorized_keys
				fi
			done < $dir_users/list
		done

		# new authorized_keys to remote server
		echo "Connect to $ipaddress ..."
		scp -i ~/.key/$oldKeypair.pem $dir_tmp/$strServer.authorized_keys ec2-user@$ipaddress:.ssh/authorized_keys
		rm $dir_tmp/$strServer.authorized_keys
		appendLogs "registerUser $strServer	$strUser"
		echo "Success: Updated new authorized_keys "

	done
}

userDeregister(){

	# select server
	local selectedServerItem=$(getServerRadiolist)
	# if not selected
	exitStatus=$?
	checkExitStatus $exitStatus
	if [ -z "$selectedServerItem" ]; then
			echo "Select one or more host."
			exit 1
	fi

	# select user
	local selectedUserArray=$(getUserChecklistByHost $selectedServerItem)
	# if not selected
	exitStatus=$?
	checkExitStatus $exitStatus
	if [ -z "${selectedUserArray[@]}" ]; then
			echo "Select one or more host."
			exit 1
	fi

	# deregister process
	## download old.authorized_keys from remote server
	oldKeypair=`cat $dir_servers/$selectedServerItem/server.info | cut -d '	' -f4`
	ipaddress=`cat $dir_servers/$selectedServerItem/server.info | cut -d '	' -f2`
	scp -i ~/.key/$oldKeypair.pem ec2-user@$ipaddress:.ssh/authorized_keys $dir_tmp/$selectedServerItem.authorized_keys

	## delete user & key info
	for selectedUserItem in ${selectedUserArray[@]};do
		### variable for delete
	  strUser=`sed -e 's/^"//' -e 's/"$//' <<<"$selectedUserItem"`

		### delete user from user.info by host
		sed -i /$strUser/d $dir_servers/$selectedServerItem/user.info

		### delete pubkey from remote server's authorized_keys
		newkeypair=`cat $dir_users/list | grep $strUser | awk '{print $2}'`
		sed -i /$newkeypair/d $dir_tmp/$selectedServerItem.authorized_keys

		# user server list update
		loginUser=`cat $dir_users/list | grep $strUser | awk '{print $3}'`
		sudo sed -i /$selectedServerItem/d /home/$loginUser/$loginUser.list
		appendLogs "deregisterUser $selectedServerItem     $strUser"
	done

	## upload new.authorized_keys to remote server
	scp -i ~/.key/$oldKeypair.pem $dir_tmp/$selectedServerItem.authorized_keys ec2-user@$ipaddress:.ssh/authorized_keys
	rm $dir_tmp/$selectedServerItem.authorized_keys
}

userInfo(){
	cat $dir_users/list
}
userInfoByServer(){
	serverArray=`ls $dir_servers`
	for server in ${serverArray[@]}; do
		echo "==================================="
		echo Server Name : $server
		echo Access Users: `cat $dir_servers/$server/user.info | awk '{print $1}'`
	done
}


case "$1" in
	add)
		userAdd
		;;
	info)
		userInfo
		;;
	byserver)
		userInfoByServer
		;;
	register)
		userRegister
		;;
	deregister)
		userDeregister
		;;
	delete)
		userDelete
		;;
	*)
		echo $"Usage: $0 {add|info|byserver|register|deregister|delete}"
		exit 1
		;;
esac
exit $?
