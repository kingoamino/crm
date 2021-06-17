SELECT 
    carte_fid_id
    , contact_id
    , num_carte_fid
    , date_creation_carte
    , code_magasin_sap
    , nb_point_expirant_3mois
    , nb_point_expirant_6mois
    , CASE WHEN
        statut_carte = true THEN 1
        ELSE 0
    END AS statut_carte
    , total_point_cumule
    , nb_parrainage
FROM marketing.carte_fidelite cf
ORDER BY cf.code_magasin_sap;