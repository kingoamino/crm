--
-- Table structure for table blacklist
--
CREATE TABLE replication_tampon.blacklist (
    CODE_CLIENT varchar(50) NOT NULL,
    NOM varchar(64) DEFAULT NULL,
    PRENOM varchar(64) DEFAULT NULL,
    DATE_INSERTION timestamp
);