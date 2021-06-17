ALTER TABLE marketing.contacts_golden
DROP COLUMN IF EXISTS bloc1_source_modif,
DROP COLUMN IF EXISTS bloc2_source_modif,
DROP COLUMN IF EXISTS bloc3_source_modif,
DROP COLUMN IF EXISTS bloc4_source_modif;

ALTER TABLE marketing.contacts_golden
DROP COLUMN IF EXISTS bloc1_date_modif,
DROP COLUMN IF EXISTS bloc2_date_modif,
DROP COLUMN IF EXISTS bloc3_date_modif,
DROP COLUMN IF EXISTS bloc4_date_modif;

ALTER TABLE replication_tampon.diapason_prisme_magasins
ALTER COLUMN zone_distribution TYPE varchar(6);

ALTER TABLE marketing.magasins
ALTER COLUMN zone_distribution TYPE varchar(6);

ALTER TABLE replication_tampon.diapason_prisme_magasins
ALTER COLUMN zone_distribution TYPE varchar(6);

ALTER TABLE marketing.agregats_contacts
ADD CONSTRAINT agregats_contacts_contact_id_fkey FOREIGN KEY (contact_id) REFERENCES marketing.contacts_golden (contact_id);

ALTER TABLE marketing.details_transactions
ADD CONSTRAINT details_transactions_contact_id_fkey FOREIGN KEY (contact_id) REFERENCES marketing.contacts_golden (contact_id);

ALTER TABLE marketing.segmentation
ADD CONSTRAINT segmentation_contact_id_fkey FOREIGN KEY (contact_id) REFERENCES marketing.contacts_golden (contact_id);

--
-- Table structure for table sas_stopcom_cc
--
CREATE TABLE espace_travail.sas_stopcom_cc (
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

CREATE TEMP VIEW vw_purge_golden AS
select contact_id
from (
	select contact_id
	, count(*) as nb_contacts
	from marketing.associations_contacts ac
	where exists(
		select 1
		from (
			select *
			from marketing.contacts_unitaires cu
			where prenom is null
				or trim(prenom) = ''
				or nom is null
				or trim(nom) = ''
				or date_naissance is null
				or trim(cast(date_naissance as varchar)) = ''
				or not exists(
					select 1
					from marketing.magasins m
					where cu.code_magasin_sap = m.code_magasin_sap
					)
		) tmp
		where ac.source_contact_id = tmp.source_contact_id
			and ac.source_creation = tmp.source_creation
	)
	group by contact_id
) tbl
where nb_contacts = 1;

\copy (SELECT * FROM vw_purge_golden) TO '/home/centos/purge_golden.csv' DELIMITER '|' CSV HEADER;

delete from marketing.associations_contacts ac
using (
	select source_contact_id
		, source_creation
	from marketing.associations_contacts ac
	where exists(
		select 1
		from (
			select *
			from marketing.contacts_unitaires cu
			where prenom is null
				or trim(prenom) = ''
				or nom is null
				or trim(nom) = ''
				or date_naissance is null
				or trim(cast(date_naissance as varchar)) = ''
				or not exists(
					select 1
					from marketing.magasins m
					where cu.code_magasin_sap = m.code_magasin_sap
					)
		) tmp
		where ac.source_contact_id = tmp.source_contact_id
			and ac.source_creation = tmp.source_creation
	)
) tbl
where tbl.source_contact_id = ac.source_contact_id
	and tbl.source_creation = ac.source_creation;

delete from marketing.contacts_unitaires cu
using (
	select source_contact_id
		, source_creation
	from marketing.contacts_unitaires cu
	where prenom is null
		or trim(prenom) = ''
		or nom is null
		or trim(nom) = ''
		or date_naissance is null
		or trim(cast(date_naissance as varchar)) = ''
		or not exists(
			select 1
			from marketing.magasins m
			where cu.code_magasin_sap = m.code_magasin_sap
		)
) tbl
where tbl.source_contact_id = cu.source_contact_id
	and tbl.source_creation = cu.source_creation;
