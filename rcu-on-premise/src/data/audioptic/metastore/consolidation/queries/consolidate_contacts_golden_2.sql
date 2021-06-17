-- Calcul de magasin principal

update marketing.contacts_golden as golden
set code_magasin_sap_principal = main_select.code_magasin_sap_principal
from (
    select
        contact_id
        , source_creation
        , nb_contacts
        , nb_transactions
        , code_magasin_sap_cu
        , code_magasin_sap_t
        , transaction_id
        , case
            when nb_transactions = 0 or nb_transactions is null then
            case 
                when nb_cosiumLight_cu = 0    
                    then FIRST_VALUE(code_magasin_sap_cu) over(
                        partition by contact_id
                        order by date_modification desc
                    )
                when nb_cosiumLight_cu > 0 then
                    FIRST_VALUE(code_magasin_sap_cu) over(
                        partition by contact_id
                        order by cosium_cu asc, date_modification desc
                    )
            end
            when nb_transactions >= 1 then
                case
                    when nb_cosiumLight_t = 0
                        then FIRST_VALUE(coalesce(code_magasin_sap_t, code_magasin_sap_cu)) over(
                            partition by contact_id
                            order by date_transaction desc
                        )
                    when nb_cosiumLight_t > 0 then
                        FIRST_VALUE(coalesce(code_magasin_sap_t, code_magasin_sap_cu)) over(
                            partition by contact_id
                            order by cosium_t asc, date_transaction desc
                        )
                end
            else null
        end as code_magasin_sap_principal
    from
        (
            select cg.contact_id
                , cg.source_creation
                , cu.code_magasin_sap as code_magasin_sap_cu
                , cu.date_modification as date_modification
                , count(*) over(
                    partition by cg.contact_id
                ) as nb_contacts
                , count(*) filter(where m.cosium = 2) over(
                    partition by cg.contact_id
                ) as nb_cosiumLight_cu
                , m.cosium as cosium_cu
            from marketing.contacts_golden cg
            join marketing.associations_contacts ac
                using(contact_id)
            join marketing.contacts_unitaires cu
                on ac.source_contact_id = cu.source_contact_id
                    and ac.source_creation = cu.source_creation
            join marketing.magasins m
                on m.code_magasin_sap = cu.code_magasin_sap
            where m.statut = 1
        ) as golden_contacts
    left join (
        select cg.contact_id
            , t.date_transaction
            , t.code_magasin_sap as code_magasin_sap_t
            , t.transaction_id
            , count(*) filter(where t.transaction_id is not null) over(
                partition by cg.contact_id
            ) as nb_transactions
            , m.statut
            , count(*) filter(where m.cosium = 2) over(
                partition by cg.contact_id
            ) as nb_cosiumLight_t
            , m.cosium as cosium_t
        from marketing.contacts_golden cg
        left join marketing.transactions t
        using(contact_id)
        join marketing.magasins m
        using(code_magasin_sap)
        where m.statut = 1
            and t.type_transaction = 1
            and t.facture_annulee = false
            and (
                t.acht_prog = true
                or t.acht_unifocal = true
                or t.acht_verre_autre = true
                or t.acht_lentille = true
            )
    ) as golden_transactions
    using(contact_id)
) as main_select
where golden.contact_id = main_select.contact_id;

update marketing.contacts_golden as golden
set type_magasin = case
        when grp_client = 'ZF'
        then 1
        else 2
    end
    , enseigne = main_select.grp_client
    , purge = case
        when statut is null
        then true
        else false
    end
from (
    select cg.contact_id
        , m.grp_client
        , m.enseigne
        , m.statut
    from marketing.contacts_golden cg
    left join marketing.magasins m
    on cg.code_magasin_sap_principal = m.code_magasin_sap
) as main_select
where golden.contact_id = main_select.contact_id;

-- Calcul ID_CARTE_FID_PRINCIPAL

update marketing.contacts_golden as golden
set ID_CARTE_FID_PRINCIPAL = main_select.CARTE_FID_ID
from (
    select distinct
        contact_id
        , FIRST_VALUE(CARTE_FID_ID) over(
            partition by contact_id
            order by TOTAL_POINT_CUMULE desc
        ) as CARTE_FID_ID
    from
        marketing.carte_fidelite
) as main_select
where golden.contact_id = main_select.contact_id;