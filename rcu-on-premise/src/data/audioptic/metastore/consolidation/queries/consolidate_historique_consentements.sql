-- Alimentation de l'historique des consentements

insert into marketing.historique_consentements
    (
        contact_id
        , consentement
        , sens_consentement
        , source
        , date_maj
        , detail_source
    )
select contact_id
    , consentement
    , sens_consentement
    , source
    , date_maj
    , detail_source
from (
    select contact_id
        , service as consentement
        , false as sens_consentement
        , 3 as source
        , date_evenement as date_maj
        , diffusion_id as detail_source
    from espace_travail.sas_desabonnement_acs
    union
    select ac.contact_id
        , 1 as consentement
        , cu.optin_email as sens_consentement
        , case
            when cu.source_creation = 'cosium'
                then 1
            when cu.source_creation = 'sas_golden'
                then 4
                else 2
        end as source
        , coalesce(cu.source_date_modification, cu.date_modification) as date_maj
        , case
            when cu.source_creation = 'cosium'
                then cu.source_contact_id
                else coalesce(cu.campagne_collecte, 'campagne_collecte_inconnue')
        end as detail_source
    from marketing.contacts_unitaires cu
    join marketing.associations_contacts ac
    using(source_contact_id)
    where cu.optin_email is not null
    union
    select ac.contact_id
        , 2 as consentement
        , cu.optin_sms as sens_consentement
        , case
            when cu.source_creation = 'cosium'
                then 1
            when cu.source_creation = 'sas_golden'
                then 4
                else 2
        end as source
        , coalesce(cu.source_date_modification, cu.date_modification) as date_maj
        , case
            when cu.source_creation = 'cosium'
                then cu.source_contact_id
                else coalesce(cu.campagne_collecte, 'campagne_collecte_inconnue')
        end as detail_source
    from marketing.contacts_unitaires cu
    join marketing.associations_contacts ac
    using(source_contact_id)
    where cu.optin_sms is not null
    union
    select ac.contact_id
        , 3 as consentement
        , cu.optin_courrier as sens_consentement
        , case
            when cu.source_creation = 'cosium'
                then 1
            when cu.source_creation = 'sas_golden'
                then 4
                else 2
        end as source
        , coalesce(cu.source_date_modification, cu.date_modification) as date_maj
        , case
            when cu.source_creation = 'cosium'
                then cu.source_contact_id
                else coalesce(cu.campagne_collecte, 'campagne_collecte_inconnue')
        end as detail_source
    from marketing.contacts_unitaires cu
    join marketing.associations_contacts ac
    using(source_contact_id)
    where cu.optin_courrier is not null
    union
    select contact_id
        , 1 as consentement
        , optin_email as sens_consentement
        , 4 as source
        , date_evenement as date_maj
        , '' as detail_source
    from espace_travail.sas_desabonnement_cc
    where optin_email is not null
    union
    select contact_id
        , 2 as consentement
        , optin_sms as sens_consentement
        , 4 as source
        , date_evenement as date_maj
        , '' as detail_source
    from espace_travail.sas_desabonnement_cc
    where optin_sms is not null
    union
    select contact_id
        , 3 as consentement
        , optin_courrier as sens_consentement
        , 4 as source
        , date_evenement as date_maj
        , '' as detail_source
    from espace_travail.sas_desabonnement_cc
    where optin_courrier is not null
) as tmp
ON CONFLICT (CONTACT_ID, CONSENTEMENT, SENS_CONSENTEMENT, SOURCE, DETAIL_SOURCE, DATE_MAJ)
DO NOTHING;
