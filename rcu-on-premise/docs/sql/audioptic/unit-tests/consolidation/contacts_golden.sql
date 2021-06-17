select 'Unicité de l''id dans la table des masters' as test, case when total_count = 0 then 'passed' else 'failed' end as result
from(
    select
        (
            select
                count(*) as val1
            from marketing.contacts_golden
        ) - (
            select
                count(distinct contact_id) as val2
            from marketing.contacts_golden
        ) as total_count
) as tc
union
select 'Il y a autant de masters uniques dans la table d''associations que de lignes dans la table des masters' as test, case when total_count = 0 then 'passed' else 'failed' end as result
from(
    select
        (
            select
                count(distinct contact_id) as val1
            from marketing.associations_contacts
        ) - (
            select
                count(*) as val2
            from marketing.contacts_golden
        ) as total_count
) as tc
union
select 'Tous les masters dans la table d''associations existent dans la table des masters' as test, case when count(*) = 0 then 'passed' else 'failed' end as result
from marketing.associations_contacts ac
where not exists(
    select 1
    from marketing.contacts_golden cg
    where ac.contact_id = cg.contact_id
)
union
select 'Tous les masters dans la table des masters existent dans la table d''associations' as test, case when count(*) = 0 then 'passed' else 'failed' end as result
from marketing.contacts_golden cg
where not exists(
    select 1
    from marketing.associations_contacts ac
    where cg.contact_id = ac.contact_id
)
union
select 'Pas de doublons sur email, prénom' as test, case when count(*) = 0 then 'passed' else 'failed' end as result
from (
    select email, prenom, row_number() over(partition by email, prenom) as rn
    from marketing.contacts_golden
    where email is not null and email <> '' and prenom is not null and prenom <> ''
) as tab
where rn > 1
union
select 'Pas de doublons sur tel_mobile, prénom' as test, case when count(*) = 0 then 'passed' else 'failed' end as result
from (
    select tel_mobile, prenom, row_number() over(partition by tel_mobile, prenom) as rn
    from marketing.contacts_golden
    where tel_mobile is not null and tel_mobile <> '' and prenom is not null and prenom <> ''
) as tab
where rn > 1
union
select 'Pas de doublons sur codepostal, nom, prénom' as test, case when count(*) = 0 then 'passed' else 'failed' end as result
from (
    select codepostal, nom, prenom, row_number() over(partition by codepostal, nom, prenom) as rn
    from marketing.contacts_golden
    where codepostal is not null and cast(codepostal as varchar) <> '' and nom is not null and nom <> '' and prenom is not null and prenom <> ''
) as tab
where rn > 1
union
select 'Aucun des masters obsolètes dans la table des masters obsolètes n''existent dans la table des masters' as test, case when count(*) = 0 then 'passed' else 'failed' end as result
from marketing.historique_golden hg
where
    exists (
        select 1 from marketing.contacts_golden cg where cg.contact_id = hg.old_contact_id
    )
union
select 'Il y a autant de lignes dans la table pre_golden que dans la tables golden' as test, case when total_count = 0 then 'passed' else 'failed' end as result
from(
    select
        (
            select
                count(*) as val1
            from espace_travail.contacts_pre_golden
        ) - (
            select
                count(*) as val2
            from marketing.contacts_golden
        ) as total_count
) as tc
union
select 'Tous les contacts pre_golden dont l''email n''est pas valide après la normalisation reste invalide après la consolidation' as test, case when count(*) = 0 then 'passed' else 'failed' end as result
from espace_travail.contacts_pre_golden cpg
join marketing.contacts_golden cg
using(contact_id)
where cpg.email_valid = false
and cpg.email_valid <> cg.email_valid
union
select 'Tous les contacts pre_golden dont le mobile n''est pas valide après la normalisation reste invalide après la consolidation' as test, case when count(*) = 0 then 'passed' else 'failed' end as result
from espace_travail.contacts_pre_golden cpg
join marketing.contacts_golden cg
using(contact_id)
where cpg.mobile_valid = false
and cpg.mobile_valid <> cg.mobile_valid
union
select 'Pas d''enregistrements avec purge = true dont le statut magasin n''est pas null' as test,
    case when count(*) = 0 then 'passed' else 'failed' end as result
from marketing.contacts_golden cg
join marketing.magasins m
on cg.code_magasin_sap_principal = m.code_magasin_sap
where cg.purge = true and m.statut is not null
union
select 'Pas d''enregistrements avec purge = false dont le statut magasin est null' as test,
    case when count(*) = 0 then 'passed' else 'failed' end as result
from marketing.contacts_golden cg
join marketing.magasins m
on cg.code_magasin_sap_principal = m.code_magasin_sap
where cg.purge = false and m.statut is null
union
select 'Pas d''enregistrements cosium avec code_magasin_sap_principal vide' as test,
    case when count(*) = 0 then 'passed' else 'failed' end as result
from marketing.contacts_golden
where code_magasin_sap_principal is null
    and source_creation = 'cosium'
union
select 'Pas de contacts golden avec source_date_modification différentre du max(source_date_modification) des contacts unitaires liés à ce golden' as test, case when count(*) = 0 then 'passed' else 'failed' end as result
from (
    select contact_id, source_date_modification
    from marketing.contacts_golden
) as cg
join (
    select ac.contact_id, cu.source_contact_id, cu.source_creation, max(cu.source_date_modification) over(partition by ac.contact_id) as max_source_date_modification
    from marketing.contacts_unitaires cu
    join marketing.associations_contacts ac
    using(source_contact_id, source_creation)
) as ac_cu
using(contact_id)
where cg.source_date_modification <> ac_cu.max_source_date_modification
union
select 'Pas d''enregistrements avec type_magasin = 1 dont le grp_client <> ''ZF''' as test,
    case when count(*) = 0 then 'passed' else 'failed' end as result
from marketing.contacts_golden cg
join marketing.magasins m
on cg.code_magasin_sap_principal = m.code_magasin_sap
where cg.type_magasin = 1 and m.grp_client <> 'ZF'
union
select 'Pas d''enregistrements avec type_magasin = 2 dont le grp_client = ''ZF''' as test,
    case when count(*) = 0 then 'passed' else 'failed' end as result
from marketing.contacts_golden cg
join marketing.magasins m
on cg.code_magasin_sap_principal = m.code_magasin_sap
where cg.type_magasin = 2 and m.grp_client = 'ZF'
union
select 'Pas d''enregistrements dont l''enseigne du magasin principal n''est pas la bonne' as test,
    case when count(*) = 0 then 'passed' else 'failed' end as result
from marketing.contacts_golden cg
join marketing.magasins m
on cg.code_magasin_sap_principal = m.code_magasin_sap
where cg.enseigne <> m.grp_client
union
select 'Pas de contacts golden flaggés à decede = false dont un des contacts unitaires est flaggé à decede = true' as test,
    case when count(*) = 0 then 'passed' else 'failed' end as result
from marketing.contacts_golden cg
where decede = false
    and exists(
        select 1
        from (
            select ac.contact_id, cu.decede
            from marketing.contacts_unitaires cu
            join marketing.associations_contacts ac
            using(source_contact_id, source_creation)
        ) as ac_cu
        where ac_cu.contact_id = cg.contact_id and ac_cu.decede = true
    )
union
select 'Pas de contacts golden flaggés à decede = true dont aucun des contacts unitaires est flaggé à decede = true' as test,
    case when count(*) = 0 then 'passed' else 'failed' end as result
from marketing.contacts_golden cg
where decede = true
    and not exists(
        select 1
        from (
            select ac.contact_id, cu.decede
            from marketing.contacts_unitaires cu
            join marketing.associations_contacts ac
            using(source_contact_id, source_creation)
        ) as ac_cu
        where ac_cu.contact_id = cg.contact_id and ac_cu.decede = true
    )
union
select 'Pas de contacts golden flaggés à anonymise = false dont un des contacts unitaires est flaggé à anonymise = true' as test,
    case when count(*) = 0 then 'passed' else 'failed' end as result
from marketing.contacts_golden cg
where anonymise = false
    and exists(
        select 1
        from (
            select ac.contact_id, cu.anonymise
            from marketing.contacts_unitaires cu
            join marketing.associations_contacts ac
            using(source_contact_id, source_creation)
        ) as ac_cu
        where ac_cu.contact_id = cg.contact_id and ac_cu.anonymise = true
    )
union
select 'Pas de contacts golden flaggés à anonymise = true dont aucun des contacts unitaires est flaggé à anonymise = true' as test,
    case when count(*) = 0 then 'passed' else 'failed' end as result
from marketing.contacts_golden cg
where anonymise = true
    and not exists(
        select 1
        from (
            select ac.contact_id, cu.anonymise
            from marketing.contacts_unitaires cu
            join marketing.associations_contacts ac
            using(source_contact_id, source_creation)
        ) as ac_cu
        where ac_cu.contact_id = cg.contact_id and ac_cu.anonymise = true
    )
union
select 'Pas de contacts golden avec date_derniere_ordo différentre du max(date_derniere_ordo) des contacts unitaires liés à ce golden' as test,
    case when count(*) = 0 then 'passed' else 'failed' end as result
from (
    select contact_id, date_derniere_ordo
    from marketing.contacts_golden
) as cg
join (
    select ac.contact_id, cu.source_contact_id, cu.source_creation, max(cu.date_derniere_ordo) over(partition by ac.contact_id) as max_date_derniere_ordo
    from marketing.contacts_unitaires cu
    join marketing.associations_contacts ac
    using(source_contact_id, source_creation)
) as ac_cu
using(contact_id)
where cg.date_derniere_ordo <> ac_cu.max_date_derniere_ordo
union
select 'Pas de contacts flaggés email_valid = true dont l''email existe dans sas_hardbounces_acs' as test,
    case when count(*) = 0 then 'passed' else 'failed' end as result
from marketing.contacts_golden cg
where cg.email_valid = true
    and exists(
        select 1
        from espace_travail.sas_hardbounces_acs sha
        where sha.adresse = cg.email
        and type = 0
    )
union
select 'Pas de contacts flaggés mobile_valid = true dont le mobile existe dans sas_hardbounces_acs' as test,
    case when count(*) = 0 then 'passed' else 'failed' end as result
from marketing.contacts_golden cg
where cg.mobile_valid = true
    and exists(
        select 1
        from espace_travail.sas_hardbounces_acs sha
        where sha.adresse = cg.email
        and type = 1
    )
union
select 'Pas de contacts flaggés adresse_valid = true dont l''adresse existe dans sas_hardbounces_alliage' as test,
    case when count(*) = 0 then 'passed' else 'failed' end as result
from marketing.contacts_golden cg
where cg.adresse_valid = true
    and exists(
        select 1
        from espace_travail.sas_hardbounces_alliage sha
        where sha.adresse = concat(cg.adresse1, cg.adresse2, cg.adresse3, cg.adresse4, cg.codepostal)
            or cg.adresse1 is null
            or cg.adresse1 = ''
            or cg.codepostal is null
            or cg.codepostal = 0
            or cast(cg.codepostal as varchar) = ''
    )
order by test;
