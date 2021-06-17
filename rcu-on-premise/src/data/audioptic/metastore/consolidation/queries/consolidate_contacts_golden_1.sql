/*
* Chargement en mode INSERT en partant de la table CONTACTS_PRE_GOLDEN.
* L'ensemble des enregsitrement de la tabme CONTACTS_PRE_GOLDEN doivent
* être présents dans la table CONTACTS_GOLDEN.
*/

insert into marketing.contacts_golden
    (
        contact_id
        , source_date_creation
        , source_date_modification
        , source_creation
        , source_creation_collecte
        , sexe
        , civilite
        , nom
        , prenom
        , date_naissance
        , optin_courrier
        , adresse_valid
        , adresse_norm
        , adresse1
        , adresse2
        , adresse3
        , adresse4
        , codepostal
        , ville
        , pays
        , code_pays
        , email
        , email_valid
        , optin_email
        , tel_fixe
        , tel_mobile
        , mobile_valid
        , optin_sms
        , date_derniere_ordo
        , anonymise
        , decede
        , purge
        , optin_fid
    )
select distinct on (contact_id)
    contact_id
    , source_date_creation
    , source_date_modification
    , source_creation
    , source_creation_collecte
    , sexe
    , civilite
    , nom
    , prenom
    , date_naissance
    , optin_courrier
    , adresse_valid
    , adresse_norm
    , adresse1
    , adresse2
    , adresse3
    , adresse4
    , codepostal
    , ville
    , pays
    , code_pays
    , email
    , email_valid
    , optin_email
    , tel_fixe
    , tel_mobile
    , mobile_valid
    , optin_sms
    , date_derniere_ordo
    , cast(anonymise as bool)
    , cast(decede as bool)
    , cast(purge as bool)
    , FALSE as optin_fid
from (
    select
        cpg.*
        , max(cu.source_date_creation) over(
            partition by cpg.contact_id
        ) as source_date_creation
        , max(cu.source_date_modification) over(
            partition by cpg.contact_id
        ) as source_date_modification
        , first_value(cu.source_creation) over(
            partition by cpg.contact_id
            order by cu.source_date_creation
        ) as source_creation
        , first_value(cu.source_creation_collecte) over(
            partition by cpg.contact_id
            order by cu.source_date_creation
        ) as source_creation_collecte
        , max(cu.date_derniere_ordo) over(
            partition by cpg.contact_id
        ) as date_derniere_ordo
        , max(
            case
                when cu.anonymise = true
                    then 1
                    else 0
            end
        ) over(
            partition by cpg.contact_id
        ) as anonymise
        , max(
            case
                when cu.decede = true
                    then 1
                    else 0
            end
        ) over(
            partition by cpg.contact_id
        ) as decede
        , case
            when m.statut is null
                then 1
                else 0
        end as purge
    from (
        select
            tmp.contact_id
            , tmp.sexe
            , tmp.civilite
            , tmp.nom
            , tmp.prenom
            , tmp.date_naissance
            , tmp.optin_courrier
            , tmp.adresse_norm
            , tmp.adresse1
            , tmp.adresse2
            , tmp.adresse3
            , tmp.adresse4
            , tmp.codepostal
            , tmp.ville
            , tmp.pays
            , coalesce(tmp.code_pays, 'non_norm') as code_pays
            , tmp.email
            , tmp.optin_email
            , tmp.tel_fixe
            , tmp.tel_mobile
            , tmp.optin_sms
            , case
                when exists(
                    select 1
                    from espace_travail.sas_hardbounces_acs sha
                    where sha.adresse = tmp.email
                        and sha.type = 0
                        and tmp.email_valid = true
                )
                    then false
                    else tmp.email_valid
            end as email_valid
            , case
                when exists(
                    select 1
                    from espace_travail.sas_hardbounces_acs sha
                    where sha.adresse = tmp.tel_mobile
                        and sha.type = 1
                        and tmp.mobile_valid = true
                )
                    then false
                    else tmp.mobile_valid
            end as mobile_valid
            , case
                when not exists(
                    select 1
                    from espace_travail.sas_hardbounces_alliage sha
                    where sha.adresse = concat(
                        tmp.adresse1, tmp.adresse2, tmp.adresse3, tmp.adresse4, tmp.codepostal
                    )
                )
                    and
                    (
                        (tmp.adresse1 is not null and tmp.adresse1 <> '')
                        or (tmp.adresse2 is not null and tmp.adresse2 <> '')
                        or (tmp.adresse3 is not null and tmp.adresse3 <> '')
                        or (tmp.adresse4 is not null and tmp.adresse4 <> '')
                    )
                    and tmp.codepostal is not null
                    and tmp.code_pays <> 'non_norm'
                then true
                else false
            end as adresse_valid
        from espace_travail.contacts_pre_golden tmp
    ) as cpg
    join marketing.associations_contacts ac
        using(contact_id)
    join marketing.contacts_unitaires cu
        using(source_contact_id, source_creation)
    left join marketing.magasins m
        using(code_magasin_sap)
) as t
order by contact_id, source_date_modification;
