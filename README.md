# shellScript


## ec2conn 
* test
```
./conn.sh test.ec2 

```


## loginManager 

### Set 
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


* Server setting 
```
./serverScript.sh add

```

* User setting 
```
./userScript.sh add 

```

* Update user information that can access the server.
```
./userScript.sh register 

```


