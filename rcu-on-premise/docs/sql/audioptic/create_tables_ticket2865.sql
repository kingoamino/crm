--
-- Table structure for table sas_maj_tel_mobile
--
CREATE TABLE espace_travail.sas_maj_tel_mobile (
	MSISDN varchar(15) NOT NULL,
	DATE_MAJ timestamp NOT NULL,
    COMMENTAIRE varchar(30) DEFAULT NULL
);

--
-- Table structure for table sas_maj_courrier
--
CREATE TABLE espace_travail.sas_maj_courrier (
	NOM varchar(64) NOT NULL,
    PRENOM varchar(64) NOT NULL,
    ADRESSE1 varchar(64) DEFAULT NULL,
    ADRESSE2 varchar(64) DEFAULT NULL,
    CP int NOT NULL,
    VILLE varchar(40) NOT NULL,
    COMMENTAIRE varchar(30) DEFAULT NULL
);