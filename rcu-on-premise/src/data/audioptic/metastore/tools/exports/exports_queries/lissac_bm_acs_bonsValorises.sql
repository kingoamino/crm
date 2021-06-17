SELECT 
    transaction_id
    , num_fact
    , contact_id
    , code_magasin_sap
    , nature_detail
    , date_transaction
    , total_net_ttc
    , type_transaction
    , nb_point_cumules
FROM marketing.bons_valorises bv
ORDER BY bv.code_magasin_sap;