--
-- Table structure for table sas_anonymisation_cc
--
CREATE TABLE espace_travail.sas_anonymisation_cc (
	ID SERIAL PRIMARY KEY,
	CONTACT_ID uuid,
	OPERATEUR varchar(80) DEFAULT NULL,
	DATE_EVENEMENT timestamp DEFAULT NULL,
	CREATED_DT timestamp DEFAULT now(),
	UPDATED_DT timestamp DEFAULT now()
);

--
-- Table structure for table sas_collecte_externe
--
CREATE TABLE espace_travail.sas_collecte_externe (
	ID SERIAL PRIMARY KEY,
	EMAIL varchar(80) DEFAULT NULL,
	SOURCE varchar(150) DEFAULT NULL,
	CAMPAGNE_COLLECTE varchar(150) DEFAULT NULL,
	DATE_COLLECTE timestamp DEFAULT NULL,
	TEL_FIXE varchar(64) DEFAULT NULL,
	TEL_MOBILE varchar(64) DEFAULT NULL,
	OPTIN_EMAIL boolean,
	OPTIN_SMS boolean,
	DATE_NAISSANCE date DEFAULT NULL,
	CIVILITE int DEFAULT NULL,
	NOM varchar(64) DEFAULT NULL,
	PRENOM varchar(64) DEFAULT NULL,
	ADRESSE1 varchar(64) DEFAULT NULL,
	ADRESSE2 varchar(64) DEFAULT NULL,
	CODEPOSTAL int DEFAULT NULL,
	VILLE varchar(40) DEFAULT NULL,
	PAYS varchar(40) DEFAULT NULL,
	TEXT_01 varchar(255) DEFAULT NULL,
	TEXT_02 varchar(255) DEFAULT NULL,
	TEXT_03 varchar(255) DEFAULT NULL,
	DATE_01 timestamp DEFAULT NULL,
	DATE_02 timestamp DEFAULT NULL,
	DATE_03 timestamp DEFAULT NULL,
	NUMERIQUE_01 double precision DEFAULT NULL,
	NUMERIQUE_02 double precision DEFAULT NULL,
	NUMERIQUE_03 double precision DEFAULT NULL,
	CREATED_DT timestamp DEFAULT now(),
	UPDATED_DT timestamp DEFAULT now()
);

--
-- Table structure for table sas_hardbounces_alliage
--
CREATE TABLE espace_travail.sas_hardbounces_alliage (
	ID SERIAL PRIMARY KEY,
    ADRESSE varchar(128),
    DATE_CREATION timestamp,
	CREATED_DT timestamp DEFAULT now(),
	UPDATED_DT timestamp DEFAULT now()
);

--
-- Table structure for table sas_alliage
--
CREATE TABLE espace_travail.sas_alliage (
	ID SERIAL PRIMARY KEY,
    SRC_CONTACT_ID varchar(72),
	DATE_ALLIAGE date,
	CTPIR varchar(6),
	FILLER_01 varchar(1),
	CODE_ETAT varchar(2),
	FILLER_02 varchar(8),
	CREATED_DT timestamp DEFAULT now(),
	UPDATED_DT timestamp DEFAULT now()
);

--
-- Table structure for table sas_desabonnement_cc
--
CREATE TABLE espace_travail.sas_desabonnement_cc (
	ID SERIAL PRIMARY KEY,
    CONTACT_ID uuid,
	OPTIN_EMAIL boolean,
	OPTIN_SMS boolean,
	OPTIN_COURRIER boolean,
	OPTIN_FID boolean,
	SOURCE int,
	OPERATEUR varchar(128),
	DATE_EVENEMENT timestamp,
	CREATED_DT timestamp DEFAULT now(),
	UPDATED_DT timestamp DEFAULT now()
);

--
-- Table structure for table sas_stopcom_cc
--
CREATE TABLE marketing.sas_stopcom_cc (
	ID SERIAL PRIMARY KEY,
    NOM varchar(64) DEFAULT NULL,
	PRENOM varchar(64) DEFAULT NULL,
	DATE_NAISSANCE date DEFAULT NULL,
	TEL_FIXE varchar(64) DEFAULT NULL,
	TEL_MOBILE varchar(64) DEFAULT NULL,
	EMAIL varchar(64) DEFAULT NULL,
	ADRESSE1 varchar(64) DEFAULT NULL,
	ADRESSE2 varchar(64) DEFAULT NULL,
	ADRESSE3 varchar(64) DEFAULT NULL,
	ADRESSE4 varchar(64) DEFAULT NULL,
	VILLE varchar(40) DEFAULT NULL,
	CODEPOSTAL int DEFAULT NULL,
	PAYS varchar(40) DEFAULT NULL,
	CREATED_DT timestamp DEFAULT now(),
	UPDATED_DT timestamp DEFAULT now()
);

--
-- Table structure for table sas_desabonnement_acs
--
CREATE TABLE espace_travail.sas_desabonnement_acs (
    CONTACT_ID uuid,
	ACTION int,
	SERVICE int,
	SOURCE int,
	DIFFUSION_ID varchar(20) DEFAULT NULL,
	DATE_EVENEMENT timestamp,
	CREATED_DT timestamp DEFAULT now(),
	UPDATED_DT timestamp DEFAULT now(),
	PRIMARY KEY (CONTACT_ID, ACTION, SERVICE, SOURCE, DATE_EVENEMENT)
);

--
-- Table structure for table sas_hardbounces_acs
--
CREATE TABLE espace_travail.sas_hardbounces_acs (
	ADRESSE varchar(128) PRIMARY KEY,
	RAISON int,
	STATUT int,
	TYPE int,
    DATE_CREATION timestamp,
	DATE_MODIFICATION timestamp,
	CREATED_DT timestamp DEFAULT now(),
	UPDATED_DT timestamp DEFAULT now()
);

--
-- Table structure for table sas_logs_diffusions_acs
--
CREATE TABLE espace_travail.sas_logs_diffusions_acs (
	LOG_ID varchar(255) PRIMARY KEY,
	CONTACT_ID uuid,
	DIFFUSION_ID varchar(20),
	DATE_CONTACT date,
	STATUT smallint,
	OUVERTURE boolean,
	CLIC boolean,
	DESABONNEMENT boolean,
	CODE_MAGASIN_SAP varchar(6),
    SEG_COURANTE_OPTIQUE varchar(50),
	SEG_COURANTE_CONTACTO varchar(50),
	SEG_COURANTE_GENERALE varchar(50),
	CREATED_DT timestamp DEFAULT now(),
	UPDATED_DT timestamp DEFAULT now()
);

--
-- Table structure for table ref_campagnes
--
CREATE TABLE marketing.ref_campagnes (
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

--
-- Table structure for table historique_consentements
--
CREATE TABLE marketing.historique_consentements (
	CONTACT_ID uuid NOT NULL,
	CONSENTEMENT smallint DEFAULT NULL,
	SENS_CONSENTEMENT boolean,
	SOURCE smallint DEFAULT NULL,
	DETAIL_SOURCE varchar(50) DEFAULT NULL,
	DIFFUSION_ID varchar(20) DEFAULT NULL,
	DATE_MAJ timestamp DEFAULT NULL,
	PRIMARY KEY (CONTACT_ID, CONSENTEMENT, SENS_CONSENTEMENT, SOURCE, DETAIL_SOURCE, DATE_MAJ),
	FOREIGN KEY (DIFFUSION_ID) REFERENCES marketing.ref_campagnes (DIFFUSION_ID)
);

--
-- Table structure for table historique_logs
--
CREATE TABLE marketing.historique_logs (
	LOG_ID varchar(255) NOT NULL,
	CONTACT_ID uuid NOT NULL,
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

--
-- Table structure for table magasin
--
CREATE TABLE marketing.magasins (
	ID_MAGASIN varchar(6) DEFAULT NULL,
	CODE_MAGASIN_SAP varchar(6) NOT NULL,
	ENSEIGNE smallint DEFAULT NULL,
	DATE_CREATION timestamp DEFAULT now(),
	DATE_MODIFICATION timestamp DEFAULT now(),
	GRP_CLIENT varchar(2) DEFAULT NULL,
	CORNERAUDIO boolean,
	RAISON_SOCIALE varchar(50) DEFAULT NULL,
	FORME_JURIDIQUE varchar(50) DEFAULT NULL,
	REPIQUAGE_ADRESSE1 varchar(40) DEFAULT NULL,
	REPIQUAGE_ADRESSE2 varchar(40) DEFAULT NULL,
	REPIQUAGE_ADRESSE3 varchar(40) DEFAULT NULL,
	REPIQUAGE_ADRESSE4 varchar(40) DEFAULT NULL,
	REPIQUAGE_CODE_POSTAL varchar(5) DEFAULT NULL,
	REPIQUAGE_VILLE varchar(40) DEFAULT NULL,
	REPIQUAGE_CODEPAYS varchar(40) DEFAULT NULL,
	REPIQUAGE_TEL_FIXE varchar(20) DEFAULT NULL,
	REPIQUAGE_EMAIL varchar(80) DEFAULT NULL,
	REPIQUAGE_TEL_MOBILE varchar(20) DEFAULT NULL,
	STATUT smallint DEFAULT NULL,
	ZONE_DISTRIBUTION varchar(6) DEFAULT NULL,
	LIBELLE_ZONE_DISTRIBUTION varchar(50) DEFAULT NULL,
	CODE_ANIMATEUR_RESEAU varchar(4) DEFAULT NULL,
	ANIMATEUR_RESEAU varchar(50) DEFAULT NULL,
	PEBV varchar(50) DEFAULT NULL,
 	AFNOR varchar(50) DEFAULT NULL,
	SITE_OPTICIEN varchar(100) DEFAULT NULL,
	LONGITUDE double precision DEFAULT NULL,
	LATITUDE double precision DEFAULT NULL,
	DATE_FERMETURE date DEFAULT NULL,
	ADHERENT_WEB_CONTACT varchar(60),
	EMAIL_WEB_CONTACT varchar(80) DEFAULT NULL,
	NOM_SPECIMEN varchar(50) DEFAULT NULL,
	PRENOM_SPECIMEN varchar(50) DEFAULT NULL,
 	SMS_SPECIMEN varchar(40) DEFAULT NULL,
	OUVERTURE_LUNDI_MATIN varchar(5),
	FERMETURE_LUNDI_MATIN varchar(5),
	OUVERTURE_LUNDI_APRESMIDI varchar(5),
	FERMETURE_LUNDI_APRESMIDI varchar(5),
	FERMETURE_LUNDI boolean,
	OUVERTURE_MARDI_MATIN varchar(5),
	FERMETURE_MARDI_MATIN varchar(5),
	OUVERTURE_MARDI_APRESMIDI varchar(5),
	FERMETURE_MARDI_APRESMIDI varchar(5),
	FERMETURE_MARDI boolean,
	OUVERTURE_MERCREDI_MATIN varchar(5),
	FERMETURE_MERCREDI_MATIN varchar(5),
	OUVERTURE_MERCREDI_APRESMIDI varchar(5),
	FERMETURE_MERCREDI_APRESMIDI varchar(5),
	FERMETURE_MERCREDI boolean,
	OUVERTURE_JEUDI_MATIN varchar(5),
	FERMETURE_JEUDI_MATIN varchar(5),
	OUVERTURE_JEUDI_APRESMIDI varchar(5),
	FERMETURE_JEUDI_APRESMIDI varchar(5),
	FERMETURE_JEUDI boolean,
	OUVERTURE_VENDREDI_MATIN varchar(5),
	FERMETURE_VENDREDI_MATIN varchar(5),
	OUVERTURE_VENDREDI_APRESMIDI varchar(5),
	FERMETURE_VENDREDI_APRESMIDI varchar(5),
	FERMETURE_VENDREDI boolean,
	OUVERTURE_SAMEDI_MATIN varchar(5),
	FERMETURE_SAMEDI_MATIN varchar(5),
	OUVERTURE_SAMEDI_APRESMIDI varchar(5),
	FERMETURE_SAMEDI_APRESMIDI varchar(5),
	FERMETURE_SAMEDI boolean,
	OUVERTURE_DIMANCHE_MATIN varchar(5),
	FERMETURE_DIMANCHE_MATIN varchar(5),
	OUVERTURE_DIMANCHE_APRESMIDI varchar(5),
	FERMETURE_DIMANCHE_APRESMIDI varchar(5),
	FERMETURE_DIMANCHE boolean,
	COSIUM smallint NOT NULL,
	AVENANT smallint,
  PRIMARY KEY (CODE_MAGASIN_SAP)
);

--
-- Table structure for table contacts_golden
--
CREATE TABLE marketing.contacts_golden (
	CONTACT_ID uuid NOT NULL,
	DATE_CREATION timestamp DEFAULT now(),
	DATE_MODIFICATION timestamp DEFAULT now(),
	SOURCE_DATE_CREATION timestamp DEFAULT NULL,
	SOURCE_DATE_MODIFICATION timestamp DEFAULT NULL,
	SOURCE_CREATION varchar(50) DEFAULT NULL,
	SOURCE_CREATION_COLLECTE varchar(50) DEFAULT NULL,
	CODE_MAGASIN_SAP_PRINCIPAL varchar(6) DEFAULT NULL,
	ID_CARTE_FID_PRINCIPAL varchar(36),
	OPTIN_FID boolean,
	TYPE_MAGASIN smallint DEFAULT NULL,
	ENSEIGNE varchar(2) DEFAULT NULL,
	SEXE smallint DEFAULT NULL,
	CIVILITE smallint DEFAULT NULL,
	NOM varchar(64) DEFAULT NULL,
	PRENOM varchar(64) DEFAULT NULL,
	DATE_NAISSANCE date DEFAULT NULL,
	OPTIN_COURRIER boolean,
	ADRESSE_VALID boolean,
	ADRESSE_NORM boolean,
	ADRESSE1 varchar(64) DEFAULT NULL,
	ADRESSE2 varchar(64) DEFAULT NULL,
	ADRESSE3 varchar(64) DEFAULT NULL,
	ADRESSE4 varchar(64) DEFAULT NULL,
	CODEPOSTAL int DEFAULT NULL,
	VILLE varchar(40) DEFAULT NULL,
	PAYS varchar(40) DEFAULT NULL,
	CODE_PAYS varchar(10) DEFAULT NULL,
	EMAIL varchar(64) DEFAULT NULL,
	EMAIL_VALID boolean,
	OPTIN_EMAIL boolean,
	TEL_FIXE varchar(64) DEFAULT NULL,
	TEL_MOBILE varchar(64) DEFAULT NULL,
	MOBILE_VALID boolean,
	OPTIN_SMS boolean,
	DATE_DERNIERE_ORDO date DEFAULT NULL,
	ANONYMISE boolean,
	DATE_ANONYMISE date,
	SOURCE_ANONYMISE int,
	DECEDE boolean,
	PURGE boolean,
  PRIMARY KEY (CONTACT_ID),
  FOREIGN KEY (CODE_MAGASIN_SAP_PRINCIPAL) REFERENCES marketing.magasins (CODE_MAGASIN_SAP),
  FOREIGN KEY (ID_CARTE_FID_PRINCIPAL) REFERENCES marketing.carte_fidelite (CARTE_FID_ID)
);

--
-- Table structure for table scores_nps
--
CREATE TABLE marketing.scores_nps (
	CONTACT_ID uuid NOT NULL,
	PRIMARY KEY (CONTACT_ID),
	FOREIGN KEY (CONTACT_ID) REFERENCES marketing.contacts_golden (CONTACT_ID)
);

--
-- Table structure for table agregat_contact
--
CREATE TABLE marketing.agregats_contacts (
	CONTACT_ID uuid NOT NULL,
	DATE_CREATION timestamp DEFAULT now(),
	DATE_MODIFICATION timestamp DEFAULT now(),
	AGE int DEFAULT NULL,
	LTV numeric(10, 2) DEFAULT NULL,
	POTENTIEL_FUTUR_PRESBYTE boolean DEFAULT NULL,
	MIXEUR int,
	ACHETEUR_36MOIS boolean,
	ACHETEUR_12MOIS boolean,
	PM_PROGRESSIFS numeric(10, 2) DEFAULT NULL,
	PM_VERRES_AUTRES numeric(10, 2) DEFAULT NULL,
	NOUVEAUX_NON_REPRIS boolean,
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
	PRIMARY KEY (CONTACT_ID),
	FOREIGN KEY (CONTACT_ID) REFERENCES marketing.contacts_golden (CONTACT_ID)
);

--
-- Table structure for table segmentation
--
CREATE TABLE marketing.segmentation (
	CONTACT_ID uuid NOT NULL,
	SEG_PRECEDENTE_OPTIQUE varchar(50),
	SEG_COURANTE_OPTIQUE varchar(50),
	SEG_PRECEDENTE_CONTACTO varchar(50),
	SEG_COURANTE_CONTACTO varchar(50),
	SEG_PRECEDENTE_GENERALE varchar(50),
	SEG_COURANTE_GENERALE varchar(50),
	PRIMARY KEY (CONTACT_ID),
	FOREIGN KEY (CONTACT_ID) REFERENCES marketing.contacts_golden (CONTACT_ID)
);

--
-- Table structure for table histo_seg
--
CREATE TABLE espace_travail.histo_seg (
	CONTACT_ID uuid NOT NULL,
	SEG_PRECEDENTE_OPTIQUE varchar(50),
	SEG_PRECEDENTE_CONTACTO varchar(50),
	SEG_PRECEDENTE_GENERALE varchar(50),
	PRIMARY KEY (CONTACT_ID)
);

--
-- Table structure for table contacts_unitaires
--
CREATE TABLE marketing.contacts_unitaires (
	SOURCE_CONTACT_ID varchar(50) NOT NULL,
	DATE_CREATION timestamp DEFAULT now(),
	DATE_MODIFICATION timestamp DEFAULT now(),
	SOURCE_DATE_CREATION timestamp DEFAULT NULL,
	SOURCE_DATE_MODIFICATION timestamp DEFAULT NULL,
	SOURCE_CREATION varchar(50) NOT NULL,
	SOURCE_CREATION_COLLECTE varchar(50),
	CAMPAGNE_COLLECTE varchar(150) DEFAULT NULL,
	CODE_MAGASIN_SAP varchar(6),
	SEXE smallint,
	CIVILITE smallint,
	NOM varchar(64) DEFAULT NULL,
	PRENOM varchar(64) DEFAULT NULL,
	DATE_NAISSANCE date DEFAULT NULL,
	OPTIN_COURRIER boolean,
	ADRESSE_NORM boolean,
	ADRESSE1 varchar(64) DEFAULT NULL,
	ADRESSE2 varchar(64) DEFAULT NULL,
	ADRESSE3 varchar(64) DEFAULT NULL,
	ADRESSE4 varchar(64) DEFAULT NULL,
	CODEPOSTAL int DEFAULT NULL,
	VILLE varchar(40) DEFAULT NULL,
	PAYS varchar(40) DEFAULT NULL,
	CODE_PAYS varchar(10) DEFAULT NULL,
	EMAIL varchar(64) DEFAULT NULL,
	EMAIL_VALID boolean,
	OPTIN_EMAIL boolean,
	TEL_MOBILE varchar(64) DEFAULT NULL,
	MOBILE_VALID boolean,
	OPTIN_SMS boolean,
	TEL_FIXE varchar(64) DEFAULT NULL,
	DATE_DERNIERE_ORDO date DEFAULT NULL,
	ANONYMISE boolean,
	DATE_ANONYMISE date,
	SOURCE_ANONYMISE int,
	DECEDE boolean,
	PRIMARY KEY (SOURCE_CONTACT_ID, SOURCE_CREATION)
);


--
-- Table structure for table contacts_pre_golden
--
CREATE TABLE espace_travail.contacts_pre_golden (
	CONTACT_ID uuid NOT NULL,
	DATE_CREATION timestamp DEFAULT now(),
	DATE_MODIFICATION timestamp DEFAULT now(),
	SEXE smallint DEFAULT NULL,
	CIVILITE smallint DEFAULT NULL,
	NOM varchar(64) DEFAULT NULL,
	PRENOM varchar(64) DEFAULT NULL,
	DATE_NAISSANCE date DEFAULT NULL,
	OPTIN_COURRIER boolean,
	ADRESSE_NORM boolean,
	ADRESSE1 varchar(64) DEFAULT NULL,
	ADRESSE2 varchar(64) DEFAULT NULL,
	ADRESSE3 varchar(64) DEFAULT NULL,
	ADRESSE4 varchar(64) DEFAULT NULL,
	CODEPOSTAL int DEFAULT NULL,
	VILLE varchar(40) DEFAULT NULL,
	PAYS varchar(40) DEFAULT NULL,
	CODE_PAYS varchar(10) DEFAULT NULL,
	EMAIL varchar(64) DEFAULT NULL,
	EMAIL_VALID boolean,
	OPTIN_EMAIL boolean,
	TEL_MOBILE varchar(64) DEFAULT NULL,
	MOBILE_VALID boolean,
	OPTIN_SMS boolean,
	TEL_FIXE varchar(64) DEFAULT NULL,
  PRIMARY KEY (CONTACT_ID)
);


--
-- Table structure for table associations_contacts
--
CREATE TABLE marketing.associations_contacts (
  CONTACT_ID uuid NOT NULL,
  SOURCE_CONTACT_ID varchar(50) NOT NULL,
  SOURCE_CREATION varchar(50) NOT NULL,
  DATE_CREATION timestamp,
  DATE_MODIFICATION timestamp,
  PRIMARY KEY (SOURCE_CONTACT_ID, SOURCE_CREATION)
);

--
-- Table structure for table historique_associations_contacts
--
CREATE TABLE espace_travail.historique_associations_contacts (
  CONTACT_ID uuid NOT NULL,
  SOURCE_CONTACT_ID varchar(50) NOT NULL,
  SOURCE_CREATION varchar(50) NOT NULL,
  DATE_CREATION timestamp,
  PRIMARY KEY (CONTACT_ID, SOURCE_CONTACT_ID, SOURCE_CREATION)
);

--
-- Table structure for table transactions
--
CREATE TABLE marketing.transactions (
    TRANSACTION_ID varchar(30) NOT NULL,
	CONTACT_ID uuid NOT NULL,
	NUM_FACT bigint DEFAULT NULL,
	NUM_AVOIR bigint DEFAULT NULL,
	CODE_MAGASIN_SAP varchar(6),
	DATE_TRANSACTION date DEFAULT NULL,
  	DATE_CREATION timestamp DEFAULT now(),
	DATE_MODIFICATION timestamp DEFAULT now(),
	TYPE_TRANSACTION int DEFAULT NULL,
	FACTURE_ANNULEE boolean,
	ACHT_PROG boolean,
	ACHT_UNIFOCAL boolean,
	ACHT_VERRE_AUTRE boolean,
	ACHT_LENTILLE boolean,
	TOTAL_PRIX_BRUT_TTC double precision DEFAULT NULL,
	TOTAL_RESTE_A_CHARGE double precision DEFAULT NULL,
	TOTAL_REMISE double precision DEFAULT NULL,
	TOTAL_NET_TTC double precision DEFAULT NULL,
	PURGE boolean,
	NB_POINT_CUMULES real,
	PRIMARY KEY (TRANSACTION_ID),
	FOREIGN KEY (CONTACT_ID) REFERENCES marketing.contacts_golden (CONTACT_ID),
	FOREIGN KEY (CODE_MAGASIN_SAP) REFERENCES marketing.magasins (CODE_MAGASIN_SAP)
);

--
-- Table structure for table details_transactions
--
CREATE TABLE marketing.details_transactions (
  	TRANSACTION_ID varchar(30) NOT NULL,
	NUM_LIGNE int NOT NULL,
	DATE_TRANSACTION date DEFAULT NULL,
    DATE_CREATION timestamp DEFAULT now(),
	DATE_MODIFICATION timestamp DEFAULT now(),
	TYPE_TRANSACTION int DEFAULT NULL,
	FACTURE_ANNULEE boolean,
	CONTACT_ID uuid NOT NULL,
	CODE_MAGASIN_SAP varchar(6) DEFAULT NULL,
	FREQUENCE_LENTILLE varchar(20) DEFAULT NULL,
	COULEUR varchar(20) DEFAULT NULL,
	MARQUE varchar(128) DEFAULT NULL,
	DIAMETRE_VERRE varchar(8) DEFAULT NULL,
	CODE_ARTICLE varchar(128) DEFAULT NULL,
	EQUIPEMENT varchar(9) DEFAULT NULL,
	GEOMETRIE varchar(11) DEFAULT NULL,
	CODE_FABRICANT int DEFAULT NULL,
	FOURNISSEUR varchar(50) DEFAULT NULL,
	FABRICANT varchar(64) DEFAULT NULL,
	CODE_GEOMETRIE int DEFAULT NULL,
	REMISE_VERRE double precision DEFAULT NULL,
	QUANTITE int DEFAULT NULL,
	TYPE_LENTILLE varchar(7) DEFAULT NULL,
	TYPE_MONTURE varchar(40) DEFAULT NULL,
	REMISE double precision DEFAULT NULL,
	TYPE_ARTICLE varchar(14) DEFAULT NULL,
	PRIX_BRUT_TTC double precision DEFAULT NULL,
	PRIX_NET_TTC double precision DEFAULT NULL,
	PURGE boolean,
	PRIMARY KEY (TRANSACTION_ID, NUM_LIGNE),
	FOREIGN KEY (TRANSACTION_ID) REFERENCES marketing.transactions (TRANSACTION_ID),
	FOREIGN KEY (CONTACT_ID) REFERENCES marketing.contacts_golden (CONTACT_ID)
);

--
-- Table structure for table historique_golden
--
CREATE TABLE marketing.historique_golden (
  	CONTACT_ID uuid NOT NULL,
	OLD_CONTACT_ID uuid NOT NULL,
  	DATE_CREATION timestamp DEFAULT now(),
	PRIMARY KEY (OLD_CONTACT_ID)
);

--
-- Table structure for table rejets
--
CREATE TABLE espace_travail.rejets (
  	ID SERIAL,
  	DATE_REJET date DEFAULT now()::timestamp,
	NOM_TABLE varchar(128),
	ETAPE_REJET int,
	RAISON_REJET int,
	REJET varchar(1000),
	CREATED_DT timestamp DEFAULT now(),
	UPDATED_DT timestamp DEFAULT now(),
	PRIMARY KEY (NOM_TABLE, ETAPE_REJET, RAISON_REJET, REJET)
);

--
-- Table structure for table sas_contacts_golden
--
CREATE TABLE espace_travail.sas_contacts_golden (
	CONTACT_ID uuid PRIMARY KEY,
	SOURCE_DATE_CREATION timestamp DEFAULT NULL,
	SOURCE_DATE_MODIFICATION timestamp DEFAULT NULL,
	SOURCE_CREATION varchar(50) DEFAULT NULL,
	SEXE smallint DEFAULT NULL,
	CIVILITE smallint DEFAULT NULL,
	NOM varchar(64) DEFAULT NULL,
	PRENOM varchar(64) DEFAULT NULL,
	DATE_NAISSANCE date DEFAULT NULL,
	ADRESSE1 varchar(64) DEFAULT NULL,
	ADRESSE2 varchar(64) DEFAULT NULL,
	ADRESSE3 varchar(64) DEFAULT NULL,
	ADRESSE4 varchar(64) DEFAULT NULL,
	CODEPOSTAL int DEFAULT NULL,
	VILLE varchar(40) DEFAULT NULL,
	PAYS varchar(40) DEFAULT NULL,
	EMAIL varchar(64) DEFAULT NULL,
	OPTIN_EMAIL boolean,
	TEL_FIXE varchar(64) DEFAULT NULL,
	TEL_MOBILE varchar(64) DEFAULT NULL,
	OPTIN_SMS boolean,
	OPTIN_COURRIER boolean,
	OPTIN_FID boolean
);

--
-- Table structure for table carte_fidelite
--
CREATE TABLE marketing.carte_fidelite (
	CARTE_FID_ID varchar(36) PRIMARY KEY,
	CONTACT_ID uuid NOT NULL,
	NUM_CARTE_FID varchar(30),
	DATE_CREATION timestamp,
	DATE_MODIFICATION timestamp,
	DATE_CREATION_CARTE timestamp NOT NULL,
	CODE_MAGASIN_SAP varchar(6),
	NB_POINT_EXPIRANT_3MOIS double precision,
	NB_POINT_EXPIRANT_6MOIS double precision,
	STATUT_CARTE boolean,
	TOTAL_POINT_CUMULE double precision,
	NB_PARRAINAGE numeric,
	FOREIGN KEY (CONTACT_ID) REFERENCES marketing.contacts_golden (CONTACT_ID),
	FOREIGN KEY (CODE_MAGASIN_SAP) REFERENCES marketing.magasins (CODE_MAGASIN_SAP)
);

--
-- Table structure for table bons_valorises
--
CREATE TABLE marketing.bons_valorises (
	TRANSACTION_ID varchar(30) PRIMARY KEY,
	NUM_FACT numeric(13) ,
	CONTACT_ID uuid NOT NULL,
	CODE_MAGASIN_SAP varchar(6)NOT NULL,
	NATURE_DETAIL varchar(30),
	DATE_CREATION timestamp DEFAULT now(),
	DATE_MODIFICATION timestamp DEFAULT now(),
	DATE_TRANSACTION date NOT NULL,
	TOTAL_NET_TTC double precision,
	TYPE_TRANSACTION numeric NOT NULL,
	NB_POINT_CUMULES real,
	FOREIGN KEY (CONTACT_ID) REFERENCES marketing.contacts_golden (CONTACT_ID)
);