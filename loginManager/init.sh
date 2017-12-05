#/bin/sh

# variable
SCRIPT=$HOME/script

# set data dirctory  
mkdir -p $HOME/data/
mkdir -p $HOME/data/servers/
mkdir -p $HOME/data/users/
mkdir -p $HOME/data/tmp/
mkdir -p $HOME/data/logs/
touch $HOME/data/users/list

# set script 
mkdir -p $HOME/script/
cp ./conn.sh $SCRIPT/
cp ./serverScript.sh $SCRIPT/
cp ./userScript.sh $SCRIPT/



