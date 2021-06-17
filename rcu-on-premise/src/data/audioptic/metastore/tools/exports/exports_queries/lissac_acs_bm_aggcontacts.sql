SELECT
    contact_id
    , age
    , ltv
    , CASE WHEN
        potentiel_futur_presbyte = TRUE THEN 1
        ELSE 0
    END AS potentiel_futur_presbyte
    , mixeur
    , CASE WHEN
        acheteur_36mois = TRUE THEN 1
        ELSE 0
    END AS acheteur_36mois
    , pm_progressifs
    , CASE WHEN
        nouveaux_non_repris = TRUE THEN 1
        ELSE 0
    END AS nouveaux_non_repris
    , CASE WHEN
        acheteur_12mois = TRUE THEN 1
        ELSE 0
    END AS acheteur_12mois
    , pm_unifocaux
    , pm_lentille
    , pm_verres_autres
    , date_prem_acht_unifocaux
    , date_dern_acht_unifocaux
    , date_prem_acht_lentille
    , date_prem_acht_progressifs
    , date_prem_acht_verre
    , date_dern_acht_lentille
    , date_dern_acht_progressifs
    , date_dern_acht_verre
    , date_prem_acht_optic
    , date_dern_acht_optic
    , date_prem_acht
    , date_dern_acht
    , CASE WHEN
        contactable_email = TRUE THEN 1
        ELSE 0
    END AS contactable_email
    , CASE WHEN
        contactable_sms = TRUE THEN 1
        ELSE 0
    END AS contactable_sms
    , CASE WHEN
        contactable_courrier = TRUE THEN 1
        ELSE 0
    END AS contactable_courrier
FROM
    marketing.agregats_contacts ac
WHERE EXISTS (
    SELECT 1
    FROM marketing.contacts_golden cg
    WHERE ac.contact_id = cg.contact_id
        AND (
            (cg.optin_email = true AND cg.email_valid = true)
            OR (cg.optin_sms = true AND cg.mobile_valid = true)
            OR (cg.optin_courrier = true AND cg.adresse_valid = true)
            OR cg.optin_fid = true
        )
);
