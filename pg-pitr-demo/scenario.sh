#!/usr/bin/env bash
#PITR demo

#start everything
docker-compose up -d

## start pgrecovery (uncomment)
docker-compose up -d

#check if base backup succeeded, then stop pgrecovery
docker-compose stop pgrecovery

# Add document
# Record time
docker exec --user=postgres pgpitrdemo_postgres_1 psql -c "SELECT NOW();"

# Add 2nd document
# stop Alfresco
docker-compose stop alfresco-core
docker-compose rm alfresco-core

# edit recovery.conf
#restore_command = 'cp /wal_archive/%f %p'
#recovery_target_time = '2018-01-09 09:39:50'
#recovery_target_action = promote

#copy and wal files
docker exec -it pgpitrdemo_postgres_1 bash
cp /var/lib/postgresql/data/PGDATA/pg_xlog/* /wal_archive/
chown -R postgres:postgres /wal_archive


#start pgrecovery
docker-compose start pgrecovery
#check if the recovery went fine

#change alfresco jdbc config
#start alfresco
docker-compose up -d
