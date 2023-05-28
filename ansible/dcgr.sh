#!/bin/bash
if [ -n "$1" ]
then
USER=$1
sudo groupadd docker
sudo usermod -aG docker ${USER}
#su -s ${USER}
sudo reboot
else
echo "No parameters found "
fi
