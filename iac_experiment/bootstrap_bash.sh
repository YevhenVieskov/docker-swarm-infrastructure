#!bin/bash
#set -e # Exit on first error
#set -x # Print expanded commands to stdout

sudo apt install -y git
sudo apt-get -y update
sudo apt-get -y install python3-pip

sudo apt-get -y update
sudo apt-get -y install ca-certificates curl gnupg lsb-release
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg


echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get -y update
sudo apt-get -y install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

sudo groupadd docker
sudo usermod -aG docker $USER
newgrp docker

sudo -i
curl -L https://github.com/docker/machine/releases/download/v0.5.5/docker-machine_linux-amd64 >/usr/local/bin/docker-machine && \
     chmod +x /usr/local/bin/docker-machine

su ubuntu
cd /home/ubuntu

#pip3 install --user boto3

pip3 --version
docker --version
docker compose version
docker-machine version



