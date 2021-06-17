-- Mise à jour des optins

-- EMAIL
update marketing.contacts_golden as cg
set
    optin_email = optin.sens_consentement
from (
    select
        contact_id
        , sens_consentement
    from (
        select
            contact_id
            , sens_consentement
            , row_number() over(
                partition by contact_id
                order by date_maj desc
            ) as optin_duplicate
        from marketing.historique_consentements
        where consentement = 1
    ) as tmp
    where optin_duplicate = 1
) as optin
where cg.contact_id = optin.contact_id;

-- SMS
update marketing.contacts_golden as cg
set
    optin_sms = optin.sens_consentement
from (
    select
        contact_id
        , sens_consentement
    from (
        select
            contact_id
            , sens_consentement
            , row_number() over(
                partition by contact_id
                order by date_maj desc
            ) as optin_duplicate
        from marketing.historique_consentements
        where consentement = 2
    ) as tmp
    where optin_duplicate = 1
) as optin
where cg.contact_id = optin.contact_id;

-- COURRIER
update marketing.contacts_golden as cg
set
    optin_courrier = optin.sens_consentement
from (
    select
        contact_id
        , sens_consentement
    from (
        select
            contact_id
            , sens_consentement
            , row_number() over(
                partition by contact_id
                order by date_maj desc
            ) as optin_duplicate
        from marketing.historique_consentements
        where consentement = 3
    ) as tmp
    where optin_duplicate = 1
) as optin
where cg.contact_id = optin.contact_id;

-- Calcul OPTIN_FID

update marketing.contacts_golden as golden
set OPTIN_FID = main_select.sens_consentement
from (
    select
    contact_id
    , sens_consentement
    from (
        select
            contact_id
            , sens_consentement
            , row_number() over(
                partition by contact_id
                order by date_maj desc
            ) as optin_duplicate
        from marketing.historique_consentements
        where consentement = 4
    ) as tmp
    where optin_duplicate = 1
) as main_select
where golden.contact_id = main_select.contact_id
and golden.id_carte_fid_principal <> '' and golden.id_carte_fid_principal is not null;

-- calcul adresse_valid

update marketing.contacts_golden as golden
set ADRESSE_VALID = false
FROM (
	select cg.contact_id
	from 
		marketing.contacts_golden cg 
		inner join 
		espace_travail.sas_alliage sa 
	on CAST(cg.contact_id as varchar) = substr(sa.src_contact_id, 9, 36)
) as main_select
where golden.contact_id = main_select.contact_id;