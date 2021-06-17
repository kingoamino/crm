--
-- Table structure for table diapason_prisme_magasins
--
CREATE TABLE replication_tampon.diapason_prisme_magasins (
  	ID_MAGASIN varchar(6) DEFAULT NULL,
	CODE_MAGASIN_SAP varchar(6) DEFAULT NULL,
	ENSEIGNE int DEFAULT NULL,
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
	EMAIL_WEB_CONTACT varchar(40) DEFAULT NULL,
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
	COSIUM smallint,
	AVENANT smallint
);

--
-- Table structure for table diapason_details_transactions
--
CREATE TABLE replication_tampon.diapason_details_transactions (
	ID_MAGASIN varchar(6) DEFAULT NULL,
  	CODE_CLIENT varchar(13) DEFAULT NULL,
	CODE_MAGASIN_SAP varchar(6) DEFAULT NULL,
	NUM_FACT bigint DEFAULT NULL,
	NUM_AVOIR bigint DEFAULT NULL,
	NUM_LIGNE int DEFAULT NULL,
	DATE_TRANSACTION date DEFAULT NULL,
  	FREQUENCE_LENTILLE varchar(20) DEFAULT NULL,
	COULEUR varchar(20) DEFAULT NULL,
	MARQUE varchar(128) DEFAULT NULL,
	DIAMETRE_VETTRE varchar(8) DEFAULT NULL,
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
	TOTAL_PRIX_HT double precision DEFAULT NULL,
	TOTAL_PRIX_BRUT_TTC double precision DEFAULT NULL,
	TOTAL_RESTE_A_CHARGE double precision DEFAULT NULL,
	TOTAL_REMISE double precision DEFAULT NULL,
	TOTAL_NET_TTC double precision DEFAULT NULL,
	NB_POINT_CUMULES real
);

--
-- Table structure for table diapason_contacts_unitaires
--
CREATE TABLE replication_tampon.diapason_contacts_unitaires (
	CODE_CLIENT varchar(13) NOT NULL,
	DATE_CREATION timestamp DEFAULT NULL,
	DATE_MODIFICATION timestamp DEFAULT NULL,
	CODE_MAGASIN_SAP varchar(6) DEFAULT NULL,
	SEXE smallint DEFAULT NULL,
	CIVILITE smallint DEFAULT NULL,
	NOM varchar(60) DEFAULT NULL,
	PRENOM varchar(60) DEFAULT NULL,
	DATE_NAISSANCE date DEFAULT NULL,
	OPTIN_COURRIER boolean,
	ADRESS_NORM boolean,
	ADRESSE1 varchar(40) DEFAULT NULL,
	ADRESSE2 varchar(40) DEFAULT NULL,
	ADRESSE3 varchar(40) DEFAULT NULL,
	ADRESSE4 varchar(40) DEFAULT NULL,
	CODEPOSTAL int DEFAULT NULL,
	VILLE varchar(40) DEFAULT NULL,
	PAYS varchar(40) DEFAULT NULL,
	EMAIL varchar(80) DEFAULT NULL,
	OPTIN_EMAIL boolean,
	TEL_FIXE varchar(20) DEFAULT NULL,
	TEL_MOBILE varchar(20) DEFAULT NULL,
	OPTIN_SMS boolean,
	DATE_DERNIERE_ORDO date DEFAULT NULL,
	DECEDE boolean,
	PRIMARY KEY (CODE_CLIENT)
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