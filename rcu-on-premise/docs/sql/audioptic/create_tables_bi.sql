-- Creating schemas
CREATE SCHEMA IF NOT EXISTS interface_db_marketing;

-- Creating table interface_db_marketing.contacts_golden
CREATE TABLE interface_db_marketing.contacts_golden (
    CONTACT_ID uuid NOT NULL,
    CODE_MAGASIN_SAP_PRINCIPAL varchar(6),
    TYPE_MAGASIN smallint,
    ENSEIGNE varchar(2),
    SEXE smallint,
    DATE_NAISSANCE date,
    OPTIN_COURRIER boolean,
    ADRESSE_VALID boolean,
    ADRESSE_NORM boolean,
    EMAIL varchar(64),
    EMAIL_VALID boolean,
    OPTIN_EMAIL boolean,
    MOBILE_VALID boolean,
    OPTIN_SMS boolean,
    DECEDE boolean,
    PURGE boolean,
    PRIMARY KEY (CONTACT_ID)
);

-- Creating table interface_db_marketing.associations_contacts
CREATE TABLE interface_db_marketing.associations_contacts (
  CONTACT_ID uuid NOT NULL,
  SOURCE_CONTACT_ID varchar(50) NOT NULL,
  SOURCE_CREATION varchar(50) NOT NULL,
  DATE_CREATION timestamp,
  DATE_MODIFICATION timestamp
);

-- Creating table interface_db_marketing.associations_contacts
CREATE TABLE interface_db_marketing.agregats_contacts (
    CONTACT_ID uuid NOT NULL,
    DATE_CREATION timestamp DEFAULT now(),
    DATE_MODIFICATION timestamp DEFAULT now(),
    AGE int DEFAULT NULL,
    LTV numeric(10, 2) DEFAULT NULL,
    POTENTIEL_FUTUR_PRESBYTE boolean DEFAULT NULL,
    MIXEUR int,
    ACHETEUR_36MOIS boolean,
    PM_PROGRESSIFS numeric(10, 2) DEFAULT NULL,
    PM_VERRES_AUTRES numeric(10, 2) DEFAULT NULL,
    NOUVEAUX_NON_REPRIS boolean,
    ACHETEUR_12MOIS boolean,
    PM_UNIFOCAUX numeric(10, 2) DEFAULT NULL,
    DATE_PREM_ACHT_UNIFOCAUX date DEFAULT NULL,
    DATE_DERN_ACHT_UNIFOCAUX date DEFAULT NULL,
    PM_LENTILLE numeric(10, 2) DEFAULT NULL,
    DATE_PREM_ACHT_LENTILLE date DEFAULT NULL,
    DATE_PREM_ACHT_PROGRESSIFS date DEFAULT NULL,
    DATE_PREM_ACHT_VERRE date DEFAULT NULL,
    DATE_DERN_ACHT_LENTILLE date DEFAULT NULL,
    DATE_DERN_ACHT_PROGRESSIFS date DEFAULT NULL,
    DATE_DERN_ACHT_VERRE date DEFAULT NULL,
    DATE_PREM_ACHT_OPTIC date DEFAULT NULL,
    DATE_DERN_ACHT_OPTIC date DEFAULT NULL,
    DATE_PREM_ACHT date DEFAULT NULL,
    DATE_DERN_ACHT date DEFAULT NULL,
    CONTACTABLE_EMAIL boolean,
    CONTACTABLE_SMS boolean,
    CONTACTABLE_COURRIER boolean,
    PRIMARY KEY (CONTACT_ID)
);

-- Creating table interface_db_marketing.historique_logs
CREATE TABLE interface_db_marketing.historique_logs (
    LOG_ID varchar(255) NOT NULL,
    CONTACT_ID uuid NOT NULL,
    DATE_CREATION timestamp DEFAULT now(),
    DATE_MODIFICATION timestamp DEFAULT now(),
    DIFFUSION_ID varchar(20) DEFAULT NULL,
    DATE_CONTACT date DEFAULT NULL,
    STATUT smallint DEFAULT NULL,
    OUVERTURE boolean,
    CLIC boolean,
    DESABONNEMENT boolean,
    CODE_MAGASIN_SAP varchar(6),
    SEG_COURANTE_OPTIQUE varchar(50),
    SEG_COURANTE_CONTACTO varchar(50),
    SEG_COURANTE_GENERALE varchar(50),
    PRIMARY KEY (LOG_ID)
);

-- Creating table interface_db_marketing.historique_consentements
CREATE TABLE interface_db_marketing.historique_consentements (
    CONTACT_ID uuid NOT NULL,
    CONSENTEMENT smallint DEFAULT NULL,
    SENS_CONSENTEMENT boolean,
    SOURCE smallint DEFAULT NULL,
    DETAIL_SOURCE varchar(50) DEFAULT NULL,
    DATE_MAJ timestamp DEFAULT NULL,
    DATE_CREATION timestamp DEFAULT now(),
    DATE_MODIFICATION timestamp DEFAULT now()
);

-- Creating table interface_db_marketing.ref_campagnes
CREATE TABLE interface_db_marketing.ref_campagnes (
    DIFFUSION_ID varchar(20) NOT NULL,
    DIFFUSION_LIBELLE varchar(255) DEFAULT NULL,
    OPERATION_LIBELLE varchar(255) DEFAULT NULL,
    PROGRAMME_LIBELLE varchar(255) DEFAULT NULL,
    ENSEIGNE smallint DEFAULT NULL,
    DATE_DEBUT date DEFAULT NULL,
    DATE_FIN date DEFAULT NULL,
    TYPE_CAMPAGNE smallint DEFAULT NULL,
    CANAL smallint DEFAULT NULL,
    CREATED_DT timestamp DEFAULT now(),
    UPDATED_DT timestamp DEFAULT now(),
    PRIMARY KEY (DIFFUSION_ID)
);

-- Creating table interface_db_marketing.segmentation
CREATE TABLE interface_db_marketing.segmentation (
    CONTACT_ID uuid,
    SEG_PRECEDENTE_OPTIQUE varchar(100),
    SEG_COURANTE_OPTIQUE varchar(100),
    SEG_PRECEDENTE_CONTACTO varchar(100),
    SEG_COURANTE_CONTACTO varchar(100),
    SEG_PRECEDENTE_GENERALE varchar(100),
    SEG_COURANTE_GENERALE varchar(100),
    PRIMARY KEY (CONTACT_ID)
);