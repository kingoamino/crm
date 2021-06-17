truncate table replication_tampon.diapason_contacts_unitaires;
truncate table marketing.sas_collecte_externe;
truncate table marketing.contacts_unitaires;

CREATE TEMP TABLE tmp_contacts(
    id_magasin varchar(255),
    grp_client varchar(255),
    code_client varchar(255),
    code_magasin varchar(255),
    enseigne varchar(255),
    type_magasin varchar(255),
    sexe varchar(255),
    civilite varchar(255),
    nom varchar(255),
    prenom varchar(255),
    datenaissance varchar(255),
    email varchar(255),
    tel_fixe varchar(255),
    tel_mobile varchar(255),
    optin_email varchar(255),
    optin_sms varchar(255),
    optin_courrier varchar(255),
    adresse1 varchar(255),
    adresse2 varchar(255),
    adresse3 varchar(255),
    adresse4 varchar(255),
    codepostal varchar(255),
    ville varchar(255),
    pays varchar(255),
    date_derniere_ordo varchar(255),
    decede varchar(255)
);
\copy tmp_contacts FROM '/home/centos/workspace/rar/contacts.csv' DELIMITER ',' CSV HEADER;
INSERT INTO replication_tampon.diapason_contacts_unitaires(code_client, nom, prenom, codepostal, email, tel_mobile)
SELECT code_client, nom, prenom, cast(case when (codepostal ~ '^[0-9]+$') = true then codepostal else NULL end as int), email, tel_mobile
FROM (
    SELECT *,
	ROW_NUMBER () OVER (
		PARTITION BY code_client
		ORDER BY
			email
	) as rn
    FROM tmp_contacts
) tmp
WHERE rn = 1;

Clés dedupcheck :

957366

Comparer email | prenom et email | nom, prenom et email

select count(distinct email) from marketing.contacts_unitaires where email is not null and email <> '';
 count
-------
 50509 + (957366 - 55979)
 951896

select count(distinct (email, prenom)) from marketing.contacts_unitaires where email is not null and email <> '' and prenom is not null and prenom <> '';
 count
-------
 54996 + (957366 - 55902)
 956460

select count(distinct (email, nom, prenom)) from marketing.contacts_unitaires where email is not null and email <> '' and nom is not null and nom <> '' and prenom is not null and prenom <> '';
 count
-------
 55411 + (957366 - 55902)
 956875

Comparer mobile | nom, prenom et mobile | mobile prénom
select count(distinct tel_mobile) from marketing.contacts_unitaires where tel_mobile is not null and tel_mobile <> '';
 count
-------
 438308 + (957366 - 497697)
 897977

select count(distinct (tel_mobile, prenom)) from marketing.contacts_unitaires where tel_mobile is not null and tel_mobile <> '' and prenom is not null and prenom <> '';
 count
-------
 490448 + (957366 - 497417)
 950397

select count(distinct (tel_mobile, nom, prenom)) from marketing.contacts_unitaires where tel_mobile is not null and tel_mobile <> '' and nom is not null and nom <> '' and prenom is not null and prenom <> '';
 count
-------
 492638 + (957366 - 497405)
 952599

src_id + src_name

+ (email + prenom mobile + nom prenom cp)
vertex    957366
cid       939898

+ (nom prenom email + nom prenom mobile + nom prenom cp)
vertex    957366
cid       947030

\copy replication_tampon.diapason_contacts_unitaires FROM '/home/centos/workspace/rar/data/contacts.csv' DELIMITER '|' CSV HEADER;