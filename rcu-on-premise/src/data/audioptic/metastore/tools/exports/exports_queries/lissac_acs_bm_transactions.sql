SELECT
    transaction_id
    , contact_id
    , num_fact
    , num_avoir
    , code_magasin_sap
    , date_transaction
    , TO_CHAR(date_creation, 'YYYY-MM-DD HH24:MI:ss') AS date_creation
    , TO_CHAR(date_modification, 'YYYY-MM-DD HH24:MI:ss') AS date_modification
    , type_transaction
    , CASE WHEN
        facture_annulee = TRUE THEN 1
        ELSE 0
    END AS facture_annulee
    , CASE WHEN
        acht_prog = TRUE THEN 1
        ELSE 0
    END AS acht_prog
    , CASE WHEN
        acht_unifocal = TRUE THEN 1
        ELSE 0
    END AS acht_unifocal
    , CASE WHEN
        acht_verre_autre = TRUE THEN 1
        ELSE 0
    END AS acht_verre_autre
    , CASE WHEN
        acht_lentille = TRUE THEN 1
        ELSE 0
    END AS acht_lentille
    , total_remise
    , total_net_ttc
    , CASE WHEN
        purge = TRUE THEN 1
        ELSE 0
    END AS purge
    , nb_point_cumules
FROM
    marketing.transactions t
WHERE EXISTS (
    SELECT 1
    FROM marketing.contacts_golden cg
    WHERE t.contact_id = cg.contact_id
        AND (
            (cg.optin_email = true AND cg.email_valid = true)
            OR (cg.optin_sms = true AND cg.mobile_valid = true)
            OR (cg.optin_courrier = true AND cg.adresse_valid = true)
            OR cg.optin_fid = true
        )
);
