#/bin/sh

# variable
SCRIPT=$HOME/script

# set dirctory  
mkdir -p $HOME/data/
mkdir -p $HOME/data/servers/
mkdir -p $HOME/data/users/
mkdir -p $HOME/data/tmp/
touch $HOME/data/users/list

# set script 
mkdir -p $HOME/script/
cp ./serverScript.sh $SCRIPT/
cp ./userScript.sh $SCRIPT/

# set logs
mkdir -p $HOME/logs/ 


