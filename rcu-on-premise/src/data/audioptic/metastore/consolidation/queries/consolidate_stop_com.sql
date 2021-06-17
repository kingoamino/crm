--updating sas_maj_tel_mobile

update espace_travail.sas_maj_tel_mobile as esmtm
set 
    commentaire = main_select.commentaire
from (
    select
        MSISDN
        , date_maj
        , tel_mobile
        , date_modification
        , case 
            when smtm.date_maj < cu.date_modification
                then 'Pas de maj BDD'
            when smtm.date_maj > cu.date_modification
                then 'MAJ_BDD'
            when smtm.date_maj = cu.date_modification
                then ''
            else
                'ABS de la BDD'
        end as commentaire
    from espace_travail.sas_maj_tel_mobile smtm
    left join marketing.contacts_unitaires cu
        on smtm.MSISDN = cu.tel_mobile
) as main_select
where esmtm.MSISDN = main_select.MSISDN;

-- updating contacts_unitaires

update marketing.contacts_unitaires as cu
set optin_sms = FALSE
from (
    select 
        MSISDN
    from espace_travail.sas_maj_tel_mobile smtm
    where smtm.commentaire = 'MAJ_BDD'
) as main
where cu.tel_mobile = main.MSISDN;

-- updating sas_maj_courrier

update espace_travail.sas_maj_courrier smc
set 
    commentaire = main_select.commentaire
from (
    select distinct on (nom, prenom, ville, cp)
        smc.nom
        , smc.prenom
        , smc.ville
        , smc.cp
        , case 
            when smc.nom = cu.nom and smc.prenom = cu.prenom and smc.ville = cu.ville and smc.cp = cu.codepostal
                then 'MAJ_BDD'
            else
                'ABS de la BDD'
        end as commentaire
    from espace_travail.sas_maj_courrier smc
    left join marketing.contacts_unitaires cu
            on smc.nom = cu.nom and smc.prenom = cu.prenom and smc.ville = cu.ville and smc.cp = cu.codepostal
) as main_select
where smc.nom = main_select.nom 
    and smc.prenom = main_select.prenom 
    and smc.ville = main_select.ville 
    and smc.cp = main_select.cp;

-- updating contacts_unitaires

update marketing.contacts_unitaires as cu
set optin_courrier = FALSE
from (
    select 
        nom
        , prenom
        , ville
        , cp
    from espace_travail.sas_maj_courrier smc
    where smc.commentaire = 'MAJ_BDD'
) as main
where cu.nom = main.nom 
    and cu.prenom = main.prenom 
    and cu.ville = main.ville 
    and cu.codepostal = main.cp;