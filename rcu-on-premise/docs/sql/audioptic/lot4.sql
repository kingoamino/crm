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

--
-- Table structure for table diapason_carte_fidelite
--
CREATE TABLE replication_tampon.diapason_carte_fidelite (
	CODE_CLIENT varchar(13) NOT NULL,
	NUM_CARTE_FID varchar(30),
	DATE_CREATION_CARTE timestamp NOT NULL,
	CODE_MAGASIN_SAP varchar(6),
	NB_POINT_EXPIRANT_3MOIS real,
	NB_POINT_EXPIRANT_6MOIS real,
	STATUT_CARTE boolean NOT NULL,
	TOTAL_POINT_CUMULE real,
	NB_PARRAINAGE numeric,
	PRIMARY KEY (NUM_CARTE_FID, CODE_MAGASIN_SAP)
);

--
-- Table structure for table diapason_bons_valorises
--
CREATE TABLE replication_tampon.diapason_bons_valorises (
	CODE_CLIENT varchar(13),
	CODE_MAGASIN_SAP varchar(6),
	ID_MAGASIN varchar(6),
	NATURE_DETAIL varchar(30),
	NUM_FACT numeric(13),
	DATE_TRANSACTION date,
	TOTAL_NET_TTC double precision,
	NB_POINT_CUMULES real,
	TYPE_TRANSACTION numeric
);

ALTER TABLE marketing.magasins
ADD COLUMN COSIUM smallint DEFAULT 0,
ADD COLUMN AVENANT smallint,
ALTER COLUMN EMAIL_WEB_CONTACT TYPE varchar(80);

ALTER TABLE marketing.transactions
ADD COLUMN NB_POINT_CUMULES real;

ALTER TABLE espace_travail.sas_contacts_golden
ADD COLUMN OPTIN_FID boolean;

ALTER TABLE marketing.contacts_golden
ADD COLUMN ID_CARTE_FID_PRINCIPAL varchar(36),
ADD COLUMN OPTIN_FID boolean,
ADD FOREIGN KEY (ID_CARTE_FID_PRINCIPAL) REFERENCES marketing.carte_fidelite (CARTE_FID_ID);

ALTER TABLE espace_travail.sas_desabonnement_cc
ADD OPTIN_FID boolean;

ALTER TABLE replication_tampon.diapason_prisme_magasins
ADD COLUMN COSIUM smallint,
ADD COLUMN AVENANT smallint;

ALTER TABLE replication_tampon.diapason_details_transactions
ADD COLUMN NB_POINT_CUMULES real;

ALTER TABLE espace_travail.sas_transaction_url_nps
RENAME COLUMN URL_QUESTIONNAIRE TO URL;

DROP TABLE IF EXISTS marketing.scores_nps;

ALTER TABLE marketing.score_nps
DROP CONSTRAINT score_nps_contact_id_fkey;