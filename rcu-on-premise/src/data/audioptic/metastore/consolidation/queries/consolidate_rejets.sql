-- Rejets

--1 : Code magasin de la table des contacts non présents dans le référentiel

insert into espace_travail.rejets
(
    nom_table
    , etape_rejet
    , raison_rejet
    , rejet
)
select distinct
	'replication_tampon.diapason_contacts_unitaires' as nom_table
    , 3 as etape_rejet
	, case
		when exist = 1 then 7
		else 1
		end as raison_rejet
    , rejet
from (
	select distinct 
		tbl::text as rejet ,
		code_client
	from replication_tampon.diapason_contacts_unitaires as tbl
	where not exists(
	    select 1
	    from replication_tampon.diapason_prisme_magasins m
	    where tbl.code_magasin_sap = m.code_magasin_sap
	)
) as main
left join (
	select distinct 
		1 as exist ,
		code_client
	from
		replication_tampon.diapason_contacts_unitaires as tbl
	where
		exists(select 1 from replication_tampon.blacklist db where tbl.code_client = db.code_client)
) as blacklist
using (code_client)
on conflict(nom_table, etape_rejet, raison_rejet, rejet)
do update
  set updated_dt = now();

--2 : Code magasin de la table des transactions (diapason) non présent dans le référentiel

insert into espace_travail.rejets
(
    nom_table
    , etape_rejet
    , raison_rejet
    , rejet
)
select distinct
	'replication_tampon.diapason_details_transactions' as nom_table
    , 4 as etape_rejet
	, case
		when exist = 1 then 8
		else 2
		end as raison_rejet
    , rejet
from (
    select distinct 
        tbl::text as rejet ,
        code_client
    from replication_tampon.diapason_details_transactions as tbl
    where not exists(
	    select 1
	    from marketing.magasins m
	    where tbl.code_magasin_sap = m.code_magasin_sap
	)
) as main
left join (
    select distinct 
        1 as exist ,
        code_client
    from
        replication_tampon.diapason_details_transactions as ddt
    where
        exists(select 1 from replication_tampon.blacklist db where ddt.code_client = db.code_client)
) as blacklist
using (code_client)
on conflict(nom_table, etape_rejet, raison_rejet, rejet)
do update
  set updated_dt = now();

--3 : Code client de la table des transactions (diapason) n'existe pas dans contacts unitaires

  insert into espace_travail.rejets
(
    nom_table
    , etape_rejet
    , raison_rejet
    , rejet
)
select distinct
	'replication_tampon.diapason_details_transactions' as nom_table
    , 4 as etape_rejet
	, case
		when exist = 1 then 8
		else 3
		end as raison_rejet
    , rejet
from (
    select distinct 
        tbl::text as rejet ,
        code_client
    from replication_tampon.diapason_details_transactions as tbl
    where not exists(
        select 1
        from marketing.contacts_unitaires c
        where tbl.code_client = c.source_contact_id
            and c.source_creation = 'cosium'
    )
) as main
left join (
    select distinct 
        1 as exist ,
        code_client
    from
        replication_tampon.diapason_details_transactions as ddt
    where
        exists(select 1 from replication_tampon.blacklist db where ddt.code_client = db.code_client)
) as blacklist
using (code_client)
on conflict(nom_table, etape_rejet, raison_rejet, rejet)
do update
  set updated_dt = now();

--4 : Prénom vide dans la table source

insert into espace_travail.rejets
(
    nom_table
    , etape_rejet
    , raison_rejet
    , rejet
)
select distinct
	'replication_tampon.diapason_contacts_unitaires' as nom_table
    , 2 as etape_rejet
	, case
		when exist = 1 then 7
		else 4
		end as raison_rejet
    , rejet
from (
    select distinct 
        tbl::text as rejet ,
        code_client
    from replication_tampon.diapason_contacts_unitaires as tbl
    where prenom is null or trim(prenom) = ''
) as main
left join (
    select distinct 
        1 as exist ,
        code_client
    from
        replication_tampon.diapason_contacts_unitaires as tbl
    where
        exists(select 1 from replication_tampon.blacklist db where tbl.code_client = db.code_client)
) as blacklist
using (code_client)
on conflict(nom_table, etape_rejet, raison_rejet, rejet)
do update
  set updated_dt = now();

--5 : Nom vide dans la table source

insert into espace_travail.rejets
(
    nom_table
    , etape_rejet
    , raison_rejet
    , rejet
)
select distinct
	'replication_tampon.diapason_contacts_unitaires' as nom_table
    , 2 as etape_rejet
	, case
		when exist = 1 then 7
		else 5
		end as raison_rejet
    , rejet
from (
    select distinct 
        tbl::text as rejet ,
        code_client
    from replication_tampon.diapason_contacts_unitaires as tbl
    where nom is null or trim(nom) = ''
) as main
left join (
    select distinct 
        1 as exist ,
        code_client
    from
        replication_tampon.diapason_contacts_unitaires as tbl
    where
        exists(select 1 from replication_tampon.blacklist db where tbl.code_client = db.code_client)
) as blacklist
using (code_client)
on conflict(nom_table, etape_rejet, raison_rejet, rejet)
do update
  set updated_dt = now();

--6 : Date de naissance vide dans la table source

insert into espace_travail.rejets
(
    nom_table
    , etape_rejet
    , raison_rejet
    , rejet
)
select distinct
	'replication_tampon.diapason_contacts_unitaires' as nom_table
    , 2 as etape_rejet
	, case
		when exist = 1 then 7
		else 6
		end as raison_rejet
    , main.rejet
from (
	select distinct 
		tbl::text as rejet ,
		code_client
	from replication_tampon.diapason_contacts_unitaires as tbl
	where date_naissance is null or trim(cast(date_naissance as varchar)) = ''
) as main
left join (
    select distinct 
        1 as exist ,
        code_client
    from
        replication_tampon.diapason_contacts_unitaires as tbl
    where
        exists(select 1 from replication_tampon.blacklist db where tbl.code_client = db.code_client)
) as blacklist
using (code_client)
on conflict(nom_table, etape_rejet, raison_rejet, rejet)
do update
  set updated_dt = now();
