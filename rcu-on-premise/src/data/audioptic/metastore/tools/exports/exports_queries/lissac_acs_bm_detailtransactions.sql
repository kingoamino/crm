SELECT
    transaction_id
    , num_ligne
    , date_transaction
    , type_transaction
    , CASE WHEN
        facture_annulee = TRUE THEN 1
        ELSE 0
    END AS facture_annulee
    , contact_id
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
    , prix_net_ttc
    , prix_brut_ttc
    , CASE WHEN
        purge = TRUE THEN 1
        ELSE 0
    END AS purge
FROM
    marketing.details_transactions dt
WHERE EXISTS (
    SELECT 1
    FROM marketing.contacts_golden cg
    WHERE dt.contact_id = cg.contact_id
        AND (
            (cg.optin_email = true AND cg.email_valid = true)
            OR (cg.optin_sms = true AND cg.mobile_valid = true)
            OR (cg.optin_courrier = true AND cg.adresse_valid = true)
            OR cg.optin_fid = true
        )
);
