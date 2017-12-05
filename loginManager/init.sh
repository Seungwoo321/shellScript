#/bin/sh

# session variable
echo `SCRIPT=$HOME/script`
echo `DATA=$HOME/data`

# set data  
mkdir -p $HOME/data/
mkdir -p $HOME/data/servers/
mkdir -p $HOME/data/users/
mkdir -p $HOME/data/tmp/
touch $HOME/data/users/list

# set script 
mkdir -p $HOME/script/
mv serverScript.sh $SCRIPT/
mv userScript.sh $SCRIPT/

# set logs
mkdir -p $HOME/logs/ 


