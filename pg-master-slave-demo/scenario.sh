#!/usr/bin/env bash
#Starting the setup with 1 master
docker-compose up -d

#Setting up the slave: Uncomment slave in compose file
docker-compose up -d

#Killing the master
docker-compose stop pgmaster

#Check if Alfresco works (read only)
#Promote the slave to master
docker exec --user=postgres pgmasterslavedemo_pgslave_1 pg_ctl promote

#Now we can again add new data to alfresco
