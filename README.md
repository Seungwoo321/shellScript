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
![serveradd_01](https://user-images.githubusercontent.com/13829929/42497618-ea63de82-8464-11e8-97b4-4d8602ec7abb.png)
![serveradd_02](https://user-images.githubusercontent.com/13829929/42497619-ea8ddea8-8464-11e8-99fa-08a53f571c64.png)
![serveradd_03](https://user-images.githubusercontent.com/13829929/42497621-eab52ac6-8464-11e8-868b-0019d3e02d5e.png)
![serveradd_04](https://user-images.githubusercontent.com/13829929/42497622-eadffc60-8464-11e8-9888-c2950e938ec5.png)
![serveradd_05](https://user-images.githubusercontent.com/13829929/42497623-eb3e42de-8464-11e8-9d8f-eebe407c45af.png)



* Create a user who can connect to the Bastion server(=local environment)
```
./userScript.sh add 
```
![useradd_01](https://user-images.githubusercontent.com/13829929/42497648-fdc3444a-8464-11e8-80c5-2ce43ee3d478.png)
![useradd_02](https://user-images.githubusercontent.com/13829929/42497649-fded5e06-8464-11e8-8493-5eac943b63a2.png)
![useradd_03](https://user-images.githubusercontent.com/13829929/42497650-fe172998-8464-11e8-95da-5d09b15b08f0.png)
![useradd_04](https://user-images.githubusercontent.com/13829929/42497651-fe4637d8-8464-11e8-9e0a-4450fa6be46d.png)

* required IAM Policy
```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "ec2:CreateKeyPair",
                "ec2:DescribeKeyPairs",
                "ec2:DeleteKeyPair"
            ],
            "Resource": "*"
        }
    ]
}
``` 

* Update user information that can access the server in login user's home directory.
```
./userScript.sh register 
```

![register_01](https://user-images.githubusercontent.com/13829929/42497657-027ac292-8465-11e8-8603-d8ca684e36fd.png)
![register_02](https://user-images.githubusercontent.com/13829929/42497658-02a30c48-8465-11e8-91e1-0996c147a3c7.png)

