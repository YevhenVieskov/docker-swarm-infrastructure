#!bin/bash
#set -e # Exit on first error
#set -x # Print expanded commands to stdout

#install git
apt install -y git

#install ansible
apt-add-repository -y ppa:ansible/ansible
apt update
apt install -y ansible

cd ~
git clone https://github.com/YevhenVieskov/docker-swarm-infrastructure.git

mkdir -p ~/.ansible/roles
mkdir -p ~/.ansible/playbooks

#copy playbooks
cp  ~/docker-swarm-infrastructure/ansible/docker_gg.yml ~/.ansible/playbooks

#install roles
ansible-galaxy install geerlingguy.pip
ansible-galaxy install geerlingguy.docker
ansible-galaxy install giovtorres.bash-completion
ansible-galaxy install giovtorres.docker-machine

#run playbooks
ansible-playbook ~/.ansible/playbooks/docker_gg.yml -u ubuntu
ansible-playbook ~/.ansible/playbooks/docker_machine_gt.yml -u ubuntu

#pip3 install --user boto3
#ansible-inventory --graph -i inventory_aws_ec2.yml