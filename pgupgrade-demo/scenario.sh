#!/usr/bin/env bash

#Lauch the Alfresco
docker-compose up -d

#dump the alfresco database
docker exec pgupgradedemo_postgresql96_1 pg_dump -Fc -s -U alfresco alfresco -f /share/alfresco.dump

#create extension pglogical on 96
docker exec pgupgradedemo_postgresql96_1 psql -c 'create extension pglogical;' -U alfresco alfresco

#create provider
docker exec pgupgradedemo_postgresql96_1 psql -c "select pglogical.create_node(node_name := 'provider', dsn := 'host=postgresql96 port=5432 dbname=alfresco');" -U alfresco alfresco

#add all tables to replication set
docker exec pgupgradedemo_postgresql96_1 psql -c "select pglogical.replication_set_add_all_tables('default', ARRAY['public']);" -U alfresco alfresco

#add all sequences to replication set
docker exec pgupgradedemo_postgresql96_1 psql -c "select pglogical.replication_set_add_all_sequences('default', ARRAY['public']);" -U alfresco alfresco

#restore the dump on postgresql 10
docker exec pgupgradedemo_postgresql10_1 pg_restore -s -U alfresco -d alfresco /share/alfresco.dump

#create extension
docker exec pgupgradedemo_postgresql10_1 psql -c 'create extension pglogical;' -U alfresco alfresco

#create subscriber
docker exec pgupgradedemo_postgresql10_1 psql -c "select pglogical.create_node(node_name := 'subscriber', dsn := 'host=postgresql10 port=5432 dbname=alfresco');" -U alfresco alfresco

#subscribe
docker exec pgupgradedemo_postgresql10_1 psql -c "select pglogical.create_subscription(subscription_name := 'subscription', provider_dsn := 'host=postgresql96 port=5432 dbname=alfresco');" -U alfresco alfresco

#check subscription
docker exec pgupgradedemo_postgresql10_1 psql -c  "select pglogical.show_subscription_status('subscription');"  -U alfresco alfresco

#sync sequences
docker exec pgupgradedemo_postgresql96_1 psql -c "SELECT pglogical.synchronize_sequence(c.relname::regclass) FROM pg_class c WHERE c.relkind = 'S';" -U alfresco alfresco