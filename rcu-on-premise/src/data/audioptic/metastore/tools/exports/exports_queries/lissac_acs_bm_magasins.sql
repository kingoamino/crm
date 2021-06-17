SELECT
    code_magasin_sap
    , enseigne
    , grp_client
    , CASE WHEN
        corneraudio = TRUE THEN 1
        ELSE 0
    END AS corneraudio
    , raison_sociale
    , forme_juridique
    , afnor
    , pebv
    , repiquage_adresse1
    , repiquage_adresse2
    , repiquage_adresse3
    , repiquage_adresse4
    , repiquage_code_postal
    , repiquage_ville
    , repiquage_codepays
    , repiquage_tel_fixe
    , repiquage_email
    , repiquage_tel_mobile
    , statut
    , zone_distribution
    , libelle_zone_distribution
    , code_animateur_reseau
    , animateur_reseau
    , site_opticien
    , longitude
    , latitude
    , date_fermeture
    , adherent_web_contact
    , email_web_contact
    , ouverture_lundi_matin
    , fermeture_lundi_matin
    , ouverture_lundi_apresmidi
    , fermeture_lundi_apresmidi
    , CASE WHEN
        fermeture_lundi = 't' THEN 1
        ELSE 0
    END AS fermeture_lundi
    , ouverture_mardi_matin
    , fermeture_mardi_matin
    , ouverture_mardi_apresmidi
    , fermeture_mardi_apresmidi
    , CASE WHEN
        fermeture_mardi = 't' THEN 1
        ELSE 0
    END AS fermeture_mardi
    , ouverture_mercredi_matin
    , fermeture_mercredi_matin
    , ouverture_mercredi_apresmidi
    , fermeture_mercredi_apresmidi
    , CASE WHEN
        fermeture_mercredi = 't' THEN 1
        ELSE 0
    END AS fermeture_mercredi
    , ouverture_jeudi_matin
    , fermeture_jeudi_matin
    , ouverture_jeudi_apresmidi
    , fermeture_jeudi_apresmidi
    , CASE WHEN
        fermeture_jeudi = 't' THEN 1
        ELSE 0
    END AS fermeture_jeudi
    , ouverture_vendredi_matin
    , fermeture_vendredi_matin
    , ouverture_vendredi_apresmidi
    , fermeture_vendredi_apresmidi
    , CASE WHEN
        fermeture_vendredi = 't' THEN 1
        ELSE 0
    END AS fermeture_vendredi
    , ouverture_samedi_matin
    , fermeture_samedi_matin
    , ouverture_samedi_apresmidi
    , fermeture_samedi_apresmidi
    , CASE WHEN
        fermeture_samedi = 't' THEN 1
        ELSE 0
    END AS fermeture_samedi
    , ouverture_dimanche_matin
    , fermeture_dimanche_matin
    , ouverture_dimanche_apresmidi
    , fermeture_dimanche_apresmidi
    , CASE WHEN
        fermeture_dimanche = 't' THEN 1
        ELSE 0
    END AS fermeture_dimanche
    , cosium
    , avenant
FROM
    marketing.magasins;