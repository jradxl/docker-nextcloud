#!/bin/bash

docker container stop nextcloud nginx-nextcloud mariadb-nextcloud
 
mkdir -p ./mariadb-data
sudo chown -R mysql:mysql ./mariadb-data

docker-compose -f docker-compose-nextcloud.yml up

