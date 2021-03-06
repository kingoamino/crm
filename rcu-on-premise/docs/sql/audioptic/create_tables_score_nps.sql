-- Creating table marketing.score_nps
CREATE TABLE marketing.score_nps(
    CONTACT_ID uuid NOT NULL,
    TRANSACTION_ID varchar(30) PRIMARY KEY,
    DATE_CREATION timestamp NOT NULL,
    DATE_MODIFICATION timestamp NOT NULL,
    CODE_MAGASIN_SAP varchar(6) NOT NULL,
    DATE_TRANSACTION date NOT NULL,
    URL_QUESTIONNAIRE varchar(255) NOT NULL,
    CANAL_COMMUNICATION int,
    DATE_ENVOI_NPS date,
    TEL_EMAIL_CLIENT varchar(60),
    MAIL_RECU boolean,
    MAIL_OUVERT boolean,
    HARDBOUNCE varchar(30),
    DATE_RELANCE date,
    TEL_EMAIL_CLIENT_RELANCE varchar(60),
    MAIL_RECU_RELANCE boolean,
    MAIL_OUVERT_RELANCE boolean,
    HARDBOUNCE_RELANCE varchar(30),
    DATE_REPONSE timestamp,
    DATE_ENVOI_EMAIL_MAG date,
    EMAIL_ENVOI_MAG varchar(60),
    EMAIL_RECU_MAG boolean,
    EMAIL_OUVERT_MAG boolean,
    HARDBOUNCE_MAG varchar(30),
    NOTE_1 numeric,
    NOTE_2 numeric,
    NOTE_3 numeric,
    NOTE_4 numeric,
    NOTE_5 numeric,
    QUESTION_1 varchar(501),
    QUESTION_2 varchar(501),
    QUESTION_3 varchar(501),
    QUESTION_4 varchar(501),
    QUESTION_5 varchar(501),
    QUESTION_6 varchar(501),
    QUESTION_7 varchar(501),
    QUESTION_8 varchar(501),
    QUESTION_9 varchar(501),
    QUESTION_10 varchar(501),
    Verbatim_1_Question_1 varchar(501),
    Verbatim_2_Question_1 varchar(501),
    Verbatim_3_Question_1 varchar(501),
    Verbatim_4_Question_1 varchar(501),
    Verbatim_5_Question_1 varchar(501),
    Verbatim_1_Question_2 varchar(501),
    Verbatim_2_Question_2 varchar(501),
    Verbatim_3_Question_2 varchar(501),
    Verbatim_4_Question_2 varchar(501),
    Verbatim_5_Question_2 varchar(501),
    Verbatim_1_Question_3 varchar(501),
    Verbatim_2_Question_3 varchar(501),
    Verbatim_3_Question_3 varchar(501),
    Verbatim_4_Question_3 varchar(501),
    Verbatim_5_Question_3 varchar(501),
    Verbatim_1_Question_4 varchar(501),
    Verbatim_2_Question_4 varchar(501),
    Verbatim_3_Question_4 varchar(501),
    Verbatim_4_Question_4 varchar(501),
    Verbatim_5_Question_4 varchar(501),
    Verbatim_1_Question_5 varchar(501),
    Verbatim_2_Question_5 varchar(501),
    Verbatim_3_Question_5 varchar(501),
    Verbatim_4_Question_5 varchar(501),
    Verbatim_5_Question_5 varchar(501),
    Verbatim_1_Question_6 varchar(501),
    Verbatim_2_Question_6 varchar(501),
    Verbatim_3_Question_6 varchar(501),
    Verbatim_4_Question_6 varchar(501),
    Verbatim_5_Question_6 varchar(501),
    Verbatim_1_Question_7 varchar(501),
    Verbatim_2_Question_7 varchar(501),
    Verbatim_3_Question_7 varchar(501),
    Verbatim_4_Question_7 varchar(501),
    Verbatim_5_Question_7 varchar(501),
    Verbatim_1_Question_8 varchar(501),
    Verbatim_2_Question_8 varchar(501),
    Verbatim_3_Question_8 varchar(501),
    Verbatim_4_Question_8 varchar(501),
    Verbatim_5_Question_8 varchar(501),
    Verbatim_1_Question_9 varchar(501),
    Verbatim_2_Question_9 varchar(501),
    Verbatim_3_Question_9 varchar(501),
    Verbatim_4_Question_9 varchar(501),
    Verbatim_5_Question_9 varchar(501),
    Verbatim_1_Question_10 varchar(501),
    Verbatim_2_Question_10 varchar(501),
    Verbatim_3_Question_10 varchar(501),
    Verbatim_4_Question_10 varchar(501),
    Verbatim_5_Question_10 varchar(501),
    FOREIGN KEY(CONTACT_ID) REFERENCES marketing.contacts_golden (CONTACT_ID)
);

-- Creating table marketing.sas_transaction_url_nps
CREATE TABLE espace_travail.sas_transaction_url_nps(
    CONTACT_ID uuid,
    TRANSACTION_ID varchar(30) PRIMARY KEY,
    URL varchar(255) NOT NULL
);

-- Creating table marketing.sas_notes_commentaire_nps
CREATE TABLE espace_travail.sas_notes_commentaire_nps(
    CONTACT_ID uuid,
    TRANSACTION_ID varchar(30) primary key,
    DATE_REPONSE timestamp NOT NULL,
    NOTE_1 numeric,
    NOTE_2 numeric,
    NOTE_3 numeric,
    NOTE_4 numeric,
    NOTE_5 numeric,
    QUESTION_1 varchar(501),
    QUESTION_2 varchar(501),
    QUESTION_3 varchar(501),
    QUESTION_4 varchar(501),
    QUESTION_5 varchar(501),
    QUESTION_6 varchar(501),
    QUESTION_7 varchar(501),
    QUESTION_8 varchar(501),
    QUESTION_9 varchar(501),
    QUESTION_10 varchar(501)
);

-- Creating table marketing.sas_item_nps
CREATE TABLE espace_travail.sas_item_nps(
    CONTACT_ID uuid,
    TRANSACTION_ID varchar(30) PRIMARY KEY,
    Verbatim_1_Question_1 varchar(501),
    Verbatim_2_Question_1 varchar(501),
    Verbatim_3_Question_1 varchar(501),
    Verbatim_4_Question_1 varchar(501),
    Verbatim_5_Question_1 varchar(501),
    Verbatim_1_Question_2 varchar(501),
    Verbatim_2_Question_2 varchar(501),
    Verbatim_3_Question_2 varchar(501),
    Verbatim_4_Question_2 varchar(501),
    Verbatim_5_Question_2 varchar(501),
    Verbatim_1_Question_3 varchar(501),
    Verbatim_2_Question_3 varchar(501),
    Verbatim_3_Question_3 varchar(501),
    Verbatim_4_Question_3 varchar(501),
    Verbatim_5_Question_3 varchar(501),
    Verbatim_1_Question_4 varchar(501),
    Verbatim_2_Question_4 varchar(501),
    Verbatim_3_Question_4 varchar(501),
    Verbatim_4_Question_4 varchar(501),
    Verbatim_5_Question_4 varchar(501),
    Verbatim_1_Question_5 varchar(501),
    Verbatim_2_Question_5 varchar(501),
    Verbatim_3_Question_5 varchar(501),
    Verbatim_4_Question_5 varchar(501),
    Verbatim_5_Question_5 varchar(501),
    Verbatim_1_Question_6 varchar(501),
    Verbatim_2_Question_6 varchar(501),
    Verbatim_3_Question_6 varchar(501),
    Verbatim_4_Question_6 varchar(501),
    Verbatim_5_Question_6 varchar(501),
    Verbatim_1_Question_7 varchar(501),
    Verbatim_2_Question_7 varchar(501),
    Verbatim_3_Question_7 varchar(501),
    Verbatim_4_Question_7 varchar(501),
    Verbatim_5_Question_7 varchar(501),
    Verbatim_1_Question_8 varchar(501),
    Verbatim_2_Question_8 varchar(501),
    Verbatim_3_Question_8 varchar(501),
    Verbatim_4_Question_8 varchar(501),
    Verbatim_5_Question_8 varchar(501),
    Verbatim_1_Question_9 varchar(501),
    Verbatim_2_Question_9 varchar(501),
    Verbatim_3_Question_9 varchar(501),
    Verbatim_4_Question_9 varchar(501),
    Verbatim_5_Question_9 varchar(501),
    Verbatim_1_Question_10 varchar(501),
    Verbatim_2_Question_10 varchar(501),
    Verbatim_3_Question_10 varchar(501),
    Verbatim_4_Question_10 varchar(501),
    Verbatim_5_Question_10 varchar(501)
);

-- Creating table marketing.sas_logs_nps_acs
CREATE TABLE espace_travail.sas_logs_nps_acs(
    CONTACT_ID uuid,
    TRANSACTION_ID varchar(30) PRIMARY KEY,
    CANAL_COMMUNICATION int,
    DATE_ENVOI_NPS date,
    TEL_EMAIL_CLIENT varchar(60),
    MAIL_RECU boolean,
    MAIL_OUVERT boolean,
    HARDBOUNCE varchar(30),
    DATE_RELANCE date,
    TEL_EMAIL_CLIENT_RELANCE varchar(60),
    MAIL_RECU_RELANCE boolean,
    MAIL_OUVERT_RELANCE boolean,
    HARDBOUNCE_RELANCE varchar(30),
    DATE_ENVOI_EMAIL_MAG date,
    EMAIL_ENVOI_MAG varchar(60),
    EMAIL_RECU_MAG boolean,
    EMAIL_OUVERT_MAG boolean,
    HARDBOUNCE_MAG varchar(30)
);