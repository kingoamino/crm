/*
* Prendre l'ensemble des transactions light de la table diapason_bons_valorises
*/

insert into marketing.bons_valorises
    (
        transaction_id
        , num_fact
        , contact_id
        , code_magasin_sap
        , nature_detail
        , date_transaction
        , total_net_ttc
        , type_transaction
        , nb_point_cumules
    )
select distinct on (transaction_id)
    transaction_id
    , num_fact
    , contact_id
    , code_magasin_sap
    , nature_detail
    , date_transaction
    , total_net_ttc
    , type_transaction
    , nb_point_cumules
    from(
        select
            concat('F', cast(dbv.code_magasin_sap as varchar), cast(dbv.num_fact as varchar)) as transaction_id
            , dbv.num_fact
            , ac.contact_id
            , dbv.code_magasin_sap
            , dbv.nature_detail
            , dbv.date_transaction
            , dbv.total_net_ttc
            , dbv.type_transaction
            , dbv.nb_point_cumules
        from replication_tampon.diapason_bons_valorises dbv 
        join marketing.associations_contacts ac
            on dbv.code_client = ac.source_contact_id
    ) as main_bons_valories;