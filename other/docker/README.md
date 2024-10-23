# Docker

# Install Docker Engine on Ubuntu
> [https://docs.docker.com/engine/install/ubuntu/](https://docs.docker.com/engine/install/ubuntu/)

## Add Docker's official GPG key:  
```
sudo apt-get update  
sudo apt-get install ca-certificates curl  
sudo install -m 0755 -d /etc/apt/keyrings  
############################################################################################################################################  
#sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc  
#sudo chmod a+r /etc/apt/keyrings/docker.asc  
sudo curl -fsSL https://mirrors.aliyun.com/docker-ce/linux/ubuntu/gpg | sudo apt-key add -  
############################################################################################################################################  
```

## Add the repository to Apt sources:  
```
############################################################################################################################################  
#echo \  
#  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \  
#  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \  
#  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null  
sudo add-apt-repository "deb [arch=amd64] https://mirrors.aliyun.com/docker-ce/linux/ubuntu $(lsb_release -cs) stable"  
############################################################################################################################################  
sudo apt-get update  
```

## To install the latest version, run:  
```
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

## Verify that the Docker Engine installation is successful by running the hello-world image:  
```
sudo docker run hello-world
```

-----

## Allow a specific non-root user to run Docker commands, run:  
```
sudo groupadd -f -r docker  
sudo usermod -aG docker ${USER}  
newgrp docker
```


## Configure a proxy for Docker Engine, run:  
```
echo -e `cat << EOF  
{  
    "proxies": {  
        "no-proxy": "*.local,localhost,127.0.0.0/8",  
        "http-proxy": "http://172.16.3.12:9999",  
        "https-proxy": "http://172.16.3.12:9999"  
    }  
}  
EOF` | sudo tee /etc/docker/daemon.json > /dev/null
```


## Enable TCP port 2375 for external connection to Docker:  
1. **/etc/docker/daemon.json**  
```
{"hosts": ["tcp://0.0.0.0:2375", "unix:///var/run/docker.sock"]}
```
2. **/etc/systemd/system/docker.service.d/override.conf**
```
[Service]  
ExecStart=  
ExecStart=/usr/bin/dockerd
```
3. Reload
```
systemctl daemon-reload
systemctl restart docker
```
>For Windows:   
>**Docker Desktop** -> **Settings** -> **General** -> **Expose daemon on tcp://localhost:2375 without TLS**  
>`netsh interface portproxy add v4tov4 listenport=2375 listenaddress=172.16.X.XXX connectaddress=127.0.0.1 connectport=2375`  

## Verify that the Expose daemon, run:  
```
docker -H tcp://172.16.X.XXX:2375 ps
```
