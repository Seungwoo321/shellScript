#/bin/sh

mkdir -p $HOME/data/
mkdir -p $HOME/script/
mkdir -p $HOME/data/servers/
mkdir -p $HOME/data/users/
touch $HOME/data/users/list
SCRIPT=$HOME/script/
DATA=$HOME/data/
mv server*.sh $SCRIPT/
mv user*.sh $SCRIPT/
export $SCRIPT $DATA