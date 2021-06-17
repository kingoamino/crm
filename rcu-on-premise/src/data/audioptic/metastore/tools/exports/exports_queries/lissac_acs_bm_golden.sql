SELECT
    cg.contact_id
    , TO_CHAR(cg.date_creation, 'YYYY-MM-DD HH24:MI:ss') AS date_creation
    , TO_CHAR(cg.date_modification, 'YYYY-MM-DD HH24:MI:ss') AS date_modification
    , TO_CHAR(cg.source_date_creation, 'YYYY-MM-DD HH24:MI:ss') AS source_date_creation
    , TO_CHAR(cg.source_date_modification, 'YYYY-MM-DD HH24:MI:ss') AS source_date_modification
    , cg.source_creation
    , cg.source_creation_collecte
    , cg.code_magasin_sap_principal
    , cg.id_carte_fid_principal
    , CASE WHEN
        cg.optin_fid = TRUE THEN 1
        ELSE 0
    END AS optin_fid
    , cg.type_magasin
    , cg.enseigne
    , cg.sexe
    , cg.civilite
    , cg.nom
    , cg.prenom
    , cg.date_naissance
    , CASE WHEN
        cg.adresse_valid = TRUE THEN 1
        ELSE 0
    END AS adresse_norm
    , regexp_replace(cg.adresse1, E'[\\n\\r]+', ' ', 'g' ) AS adresse1
    , regexp_replace(cg.adresse2, E'[\\n\\r]+', ' ', 'g' ) AS adresse2
    , regexp_replace(cg.adresse3, E'[\\n\\r]+', ' ', 'g' ) AS adresse3
    , regexp_replace(cg.adresse4, E'[\\n\\r]+', ' ', 'g' ) AS adresse4
    , cg.codepostal
    , cg.ville
    , cg.pays
    , cg.code_pays
    , cg.email
    , cg.tel_mobile
    , cg.date_derniere_ordo
    , CASE WHEN
        cg.anonymise = TRUE THEN 1
        ELSE 0
    END AS anonymise
    , CASE WHEN
        cg.decede = TRUE THEN 1
        ELSE 0
    END AS decede
    , CASE WHEN
        cg.purge = TRUE THEN 1
        ELSE 0
    END AS purge
    , sg.seg_courante_optique
    , sg.seg_precedente_optique
    , sg.seg_courante_contacto
    , sg.seg_precedente_contacto
    , sg.seg_courante_generale
    , sg.seg_precedente_generale
    FROM
        marketing.contacts_golden as cg
            LEFT JOIN
        marketing.segmentation as sg
            USING (contact_id)
    WHERE (optin_email = true and email_valid = true)
        or (optin_sms = true and mobile_valid = true)
        or (optin_courrier = true and adresse_valid = true)
        or optin_fid = true;
