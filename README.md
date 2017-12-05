# shellScript


## ec2conn 
* test
```
./conn.sh test.ec2 
```


## loginManager 


### Note
* Tested in Amazon Linux environment.
* This script has been set up to set the bastion environment.
* The remote server only connects to ec2-user. (conn.sh) 


### Setup
```
git clone https://github.com/Seungwoo321/shellScript.git
cd shellScript/loginManager 
./init.sh 
cd ~/script/
chmod 755 *.sh
```

### Command 

* userScript.sh 
```
./userScript.sh add
./userScript.sh info
./userScript.sh byserver
./userScript.sh register
./userScript.sh deregister
./userScript.sh delete
```
* serverScript.sh
```
./serverScript.sh add
./serverScript.sh info
./serverScript.sh update
./serverScript.sh delete
```


### Usage Example


* Add server information to manage access.
```
./serverScript.sh add
```

* Create a user who can connect to the Bastion server(=local environment)
```
./userScript.sh add 
```

* Update user information that can access the server in login user's home directory.
```
./userScript.sh register 
```


