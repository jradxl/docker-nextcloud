#!/bin/bash
#docker container stop $(docker container ls -aq)
#docker container rm $(docker container ls -aq)

docker container stop mariadb-nextcloud
docker container rm mariadb-nextcloud

docker image rm mariadb-image:nextcloud
docker image    prune -af
docker system   prune -af

#docker image ls -a
#docker container ls -a

USER=mysql
CUSER=$(id -u -n)
CGROUP=$(id -g -n)

##If the database files exist, then when rebuilding
##the ownership must be the current User
sudo chown -R $CUSER:mysql ./mariadb-data

#Find if Group and Passwd entries are present
AGP=$(getent group  | grep "\b$USER\b" | awk -F: '{print $3}')
APW=$(getent passwd | grep "\b$USER\b" | awk -F: '{print $3}')

if [ "x$AGP" == "x" ]; then
    echo "Adding new group entry"
    #Get next available GROUP
    GP=$(getent group  | sort -k3 -n -t: | awk -F: 'BEGIN { current=100; previous=101;} ($3>100) && ($3<999) { previous=current; current=$3; if (current!=previous+1) {print previous+1; exit;} }')
    sudo groupadd -g $GP $USER
else
    GP=$AGP
fi

if [ "x$APW" == "x" ]; then
    echo "Adding new password entry"
    PW=$(getent passwd | sort -k3 -n -t: | awk -F: 'BEGIN { current=100; previous=101;} ($3>100) && ($3<999) { previous=current; current=$3; if (current!=previous+1) {print previous+1; exit;} }')
    sudo useradd -c "Mariadb Server User" -M -r -s /bin/false -d /nonexistent -u $PW -g $GP $USER
else
    PW=$APW
fi

export GPID=$GP
export PWID=$PW

#COMPOSE_DOCKER_CLI_BUILD=1 DOCKER_BUILDKIT=1 docker-compose -f docker-compose-mariadb.yml build
#COMPOSE_DOCKER_CLI_BUILD=1 DOCKER_BUILDKIT=1 docker-compose -f docker-compose-mariadb.yml up
docker-compose -f docker-compose-mariadb.yml build

#Start
#docker-compose -f docker-compose-mariadb.yml up

#Examine
#docker exec -it mariadb-nextcloud bash

