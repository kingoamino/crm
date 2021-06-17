#!/bin/bash

# Downloading CSV files from SFTP serveur
export SSHPASS=$AUDIOPTIC_SFTP_PASSWORD
sshpass -e sftp -oBatchMode=no -b - $AUDIOPTIC_SFTP_LOGIN@$AUDIOPTIC_SFTP_HOST << !
   get /LineUp7/synkro_bdd/*.csv /home/user_crm/synkro_bdd/
   bye
!

# uploading replication into DB 
export PGPASSWORD=$AUDIOPTIC_DB_PWD
psql -h $AUDIOPTIC_DB_HOST -p 5432 -U $AUDIOPTIC_DB_USER -f ~/rcu-on-premise/docs/sql/audioptic/import_into_replication_tables.sql -d $AUDIOPTIC_DB_NAME