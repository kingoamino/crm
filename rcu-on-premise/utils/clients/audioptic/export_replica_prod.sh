#!/bin/bash

# Creat replication copy
export PGPASSWORD=$AUDIOPTIC_DB_PWD
psql -h $AUDIOPTIC_DB_HOST -p 5432 -U $AUDIOPTIC_DB_USER -f ~/rcu-on-premise/docs/sql/audioptic/copy_replication_tables.sql -d $AUDIOPTIC_DB_NAME

# Transfering CSV files to SFTP serveur recette

export SSHPASS=$AUDIOPTIC_SFTP_PASSWORD
sshpass -e sftp -oBatchMode=no -b - $AUDIOPTIC_SFTP_LOGIN@$AUDIOPTIC_SFTP_HOST_REC << !
   put /home/user_crm/synkro_bdd/*.csv /LineUp7/synkro_bdd
   bye
!

# Transfering CSV files to SFTP serveur preprod

export SSHPASS=$AUDIOPTIC_SFTP_PASSWORD
sshpass -e sftp -oBatchMode=no -b - $AUDIOPTIC_SFTP_LOGIN@$AUDIOPTIC_SFTP_HOST_PreProd << !
   put /home/user_crm/synkro_bdd/*.csv /LineUp7/synkro_bdd
   bye
!