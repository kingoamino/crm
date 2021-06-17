/*
* Prendre l'ensemble des transactions de la table diapason_details_transactions des contacts
* unitaires associés au Golden et dédupliquer sur le champ calculé TRANSACTION_ID
*/

insert into marketing.transactions
    (
        transaction_id
        , contact_id
        , num_fact
        , num_avoir
        , code_magasin_sap
        , date_transaction
        , type_transaction
        , facture_annulee
        , acht_prog
        , acht_unifocal
        , acht_verre_autre
        , acht_lentille
        , total_prix_brut_ttc
        , total_reste_a_charge
        , total_remise
        , total_net_ttc
        , purge
        , nb_point_cumules
    )
select distinct on (transaction_id)
    transaction_id
    , contact_id
    , num_fact
    , num_avoir
    , code_magasin_sap
    , date_transaction
    , type_transaction
    , cast(facture_annulee as bool)
    , cast(acht_prog as bool)
    , cast(acht_unifocal as bool)
    , cast(acht_verre_autre as bool)
    , cast(acht_lentille as bool)
    , total_prix_brut_ttc
    , total_reste_a_charge
    , total_remise
    , total_net_ttc
    , cast(purge as bool)
    , nb_point_cumules
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
        , max(
            case
                when code_geometrie = 3
                    then 1
                    else 0
            end
        ) over(
            partition by
                case
                    when ddt.num_avoir = 0 and ddt.num_fact > 0
                        then concat('F', cast(ddt.code_magasin_sap as varchar), cast(ddt.num_fact as varchar))
                        else concat('A', cast(ddt.code_magasin_sap as varchar), cast(ddt.num_avoir as varchar))
                end
        ) as acht_prog
        , max(
            case
                when code_geometrie = 5
                    then 1
                    else 0
            end
        ) over(
            partition by
                case
                    when ddt.num_avoir = 0 and ddt.num_fact > 0
                        then concat('F', cast(ddt.code_magasin_sap as varchar), cast(ddt.num_fact as varchar))
                        else concat('A', cast(ddt.code_magasin_sap as varchar), cast(ddt.num_avoir as varchar))
                end
        ) as acht_unifocal
        , max(
            case
                when lower(type_article) in ('verre', 'monture')
                    then 1
                    else 0
            end
        ) over(
            partition by
                case
                    when ddt.num_avoir = 0 and ddt.num_fact > 0
                        then concat('F', cast(ddt.code_magasin_sap as varchar), cast(ddt.num_fact as varchar))
                        else concat('A', cast(ddt.code_magasin_sap as varchar), cast(ddt.num_avoir as varchar))
                end
        ) as acht_verre_autre
        , max(
            case
                when lower(type_article) = 'lentille'
                    then 1
                    else 0
            end
        ) over(
            partition by
                case
                    when ddt.num_avoir = 0 and ddt.num_fact > 0
                        then concat('F', cast(ddt.code_magasin_sap as varchar), cast(ddt.num_fact as varchar))
                        else concat('A', cast(ddt.code_magasin_sap as varchar), cast(ddt.num_avoir as varchar))
                end
        ) as acht_lentille
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
) as t
order by transaction_id, date_transaction;
