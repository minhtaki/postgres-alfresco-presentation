#!/usr/bin/env bash
#PITR demo

#start everything
docker-compose up -d

#check if base backup succeeded, then stop pgrecovery
docker-compose stop pgrecovery

# Add document
# Record time
docker exec --user=postgres pgpitrdemo_postgres_1 psql -c "SELECT NOW();"
# 2018-01-15 10:55:49.866192+00

# Remove document, also from trash

# edit recovery.conf
#restore_command = 'cp /wal_archive/%f %p'
#recovery_target_time = '2018-01-09 09:39:50'
#recovery_target_action = promote

#show the xlog files
docker exec -it --user=postgres pgpitrdemo_postgres_1 ls /wal_archive

#force wal file switch
docker exec -it --user=postgres pgpitrdemo_postgres_1 psql -c 'SELECT pg_switch_xlog()'

#show the xlog files again
docker exec -it --user=postgres pgpitrdemo_postgres_1 ls /wal_archive

#start pgrecovery
docker-compose start pgrecovery
#check if the recovery went fine

#stop master postgres to force switch
docker-compose stop postgres
