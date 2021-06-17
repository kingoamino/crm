select 'Pas d''enregistrements avec prénom ou nom ou date denaissance vides' as test,
    case when count(*) = 0 then 'passed' else 'failed' end as result
from marketing.contacts_unitaires
where source_creation <> 'sas_golden'
    and (
        prenom is null
        or trim(prenom) = ''
        or nom is null
        or trim(nom) = ''
        or date_naissance is null
        or trim(cast(date_naissance as varchar)) = ''
    )
union
select 'Pas d''enregistrements cosium non liés à un magasin' as test,
    case when count(*) = 0 then 'passed' else 'failed' end as result
from marketing.contacts_unitaires as cu
where not exists(
    select 1
    from marketing.magasins m
    where cu.code_magasin_sap = m.code_magasin_sap
)
    and source_creation = 'cosium';
