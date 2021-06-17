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
select 'Il y a autant de lignes dans la table d''associations, que dans la table des contacts normalisés' as test, case when total_count = 0 then 'passed' else 'failed' end as result
from(
    select
        (
            select
                count(*) as val1
            from marketing.associations_contacts
        ) - (
            select
                count(*) as val2
            from marketing.contacts_unitaires
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
select 'Pas de doublons sur date_naissance, nom, prénom' as test, case when count(*) = 0 then 'passed' else 'failed' end as result
from (
    select date_naissance, nom, prenom, row_number() over(partition by date_naissance, nom, prenom) as rn
    from marketing.contacts_golden
    where date_naissance is not null and cast(date_naissance as varchar) <> '' and nom is not null and nom <> '' and prenom is not null and prenom <> ''
) as tab
where rn > 1;
