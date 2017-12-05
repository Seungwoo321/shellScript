#!/bin/bash

PWD=`pwd`
KEYDIR=$PWD/.key
hosts=()
users=()
ips=()
keypairs=()

if [ -r $1 ]  && [ $# -eq 1 ]
then 


	while read host	user ip key region
	do
		hosts=(${hosts[@]} $host)
		users=(${users[@]} $user)
		ips=(${ips[@]} $ip)
		keypairs=(${keypairs[@]} $key)
	done < $1
	
	PS3="Enter the server host you want to connect : "
	select host in ${hosts[@]}
	do
		for index in ${!hosts[@]}
		do
			case $host in
				${hosts[$index]})
					echo -e "Connect to \E[37;44m\033[1m$host ${ips[$index]}\033[0m ..."
					ssh -i $KEYDIR/${keypairs[$index]} ${users[$index]}@${ips[$index]}
					exit 1
					;;
			esac
		done
	done

else
	echo "" 
        echo "# Usage : ./conn.sh test.ec2" 
        echo "# I need a file with server information"
	echo ""
fi


