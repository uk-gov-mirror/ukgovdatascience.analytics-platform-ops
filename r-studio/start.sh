#!/bin/sh
set -e

USER=${USER:=rstudio}
GROUP=staff

if ! getent passwd $USER > /dev/null 2>&1; then
    #sudo useradd -g $GROUP -m -d /home/$USER -s /dev/null $USER
    sudo useradd -g $GROUP -m -d /home/$USER -s /bin/bash $USER
    echo "${USER}:${USER}" | chpasswd
fi

/usr/lib/rstudio-server/bin/rserver --server-daemonize 0
