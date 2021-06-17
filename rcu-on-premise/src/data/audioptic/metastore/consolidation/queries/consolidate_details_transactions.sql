/*
* Prendre l'ensemble des transactions de la table diapason_details_transactions des contacts
* unitaires associés au Golden
*/

insert into marketing.details_transactions
    (
        transaction_id
        , num_ligne
        , date_transaction
        , type_transaction
        , facture_annulee
        , contact_id
        , code_magasin_sap
        , frequence_lentille
        , couleur
        , marque
        , diametre_verre
        , code_article
        , equipement
        , geometrie
        , code_fabricant
        , fournisseur
        , fabricant
        , code_geometrie
        , remise_verre
        , quantite
        , type_lentille
        , type_monture
        , remise
        , type_article
        , prix_brut_ttc
        , prix_net_ttc
        , purge
    )
select distinct on (transaction_id, num_ligne)
    transaction_id
    , num_ligne
    , date_transaction
    , type_transaction
    , cast(facture_annulee as bool)
    , contact_id
    , code_magasin_sap
    , frequence_lentille
    , couleur
    , marque
    , diametre_vettre
    , code_article
    , equipement
    , geometrie
    , code_fabricant
    , fournisseur
    , fabricant
    , code_geometrie
    , remise_verre
    , quantite
    , type_lentille
    , type_monture
    , remise
    , type_article
    , prix_brut_ttc
    , prix_net_ttc
    , cast(purge as bool)
from (
    select
        ddt.*
        , ac.contact_id
        , case
            when ddt.num_avoir = 0 and ddt.num_fact > 0
                then concat('F', cast(ddt.code_magasin_sap as varchar), cast(ddt.num_fact as varchar))
                else concat('A', cast(ddt.code_magasin_sap as varchar), cast(ddt.num_avoir as varchar))
        end as transaction_id
        , case
            when ddt.num_avoir = 0 and ddt.num_fact > 0
                then 1
                else 2
        end as type_transaction
        , case
            when ddt.num_avoir > 0
                then 1
                else 0
        end as facture_annulee
        , case
            when m.statut is null
                then 1
                else 0
        end as purge
    from replication_tampon.diapason_details_transactions ddt
    join marketing.associations_contacts ac
        on ddt.code_client = ac.source_contact_id
    join marketing.magasins m
        using(code_magasin_sap)
    where ac.source_creation = 'cosium'
) as dt
order by transaction_id, num_ligne, date_transaction;
