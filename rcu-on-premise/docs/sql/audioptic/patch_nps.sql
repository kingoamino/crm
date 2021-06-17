-- Modification constraint for table sas_logs_nps_acs

alter table espace_travail.sas_logs_nps_acs
alter column CONTACT_ID set not null,
alter column CANAL_COMMUNICATION drop not null,
alter column DATE_ENVOI_NPS drop not null,
alter column TEL_EMAIL_CLIENT drop not null,
alter column MAIL_RECU drop not null,
alter column MAIL_OUVERT drop not null,
alter column HARDBOUNCE drop not null,
alter column DATE_RELANCE drop not null,
alter column TEL_EMAIL_CLIENT_RELANCE drop not null,
alter column MAIL_RECU_RELANCE drop not null,
alter column MAIL_OUVERT_RELANCE drop not null,
alter column HARDBOUNCE_RELANCE drop not null,
alter column DATE_ENVOI_EMAIL_MAG drop not null,
alter column EMAIL_ENVOI_MAG drop not null,
alter column EMAIL_RECU_MAG drop not null,
alter column EMAIL_OUVERT_MAG drop not null,
alter column HARDBOUNCE_MAG drop not null;

-- modification constraint for table score_nps

alter table marketing.score_nps
alter column CANAL_COMMUNICATION drop not null,
alter column DATE_ENVOI_NPS drop not null,
alter column MAIL_RECU drop not null,
alter column MAIL_OUVERT drop not null,
alter column HARDBOUNCE drop not null,
alter column DATE_RELANCE drop not null,
alter column TEL_EMAIL_CLIENT_RELANCE drop not null,
alter column MAIL_RECU_RELANCE drop not null,
alter column MAIL_OUVERT_RELANCE drop not null,
alter column DATE_REPONSE drop not null,
alter column DATE_ENVOI_EMAIL_MAG drop not null,
alter column EMAIL_ENVOI_MAG drop not null,
alter column EMAIL_RECU_MAG drop not null,
alter column EMAIL_OUVERT_MAG drop not null,
alter column HARDBOUNCE_MAG drop not null;