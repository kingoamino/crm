/*
* Prendre l'ensemble des carte_fid de la table diapason_carte_fidelite des contacts
*/

insert into marketing.carte_fidelite
    (
        CARTE_FID_ID
        , CONTACT_ID
        , NUM_CARTE_FID
        , DATE_CREATION
        , DATE_MODIFICATION
        , DATE_CREATION_CARTE
        , CODE_MAGASIN_SAP
        , NB_POINT_EXPIRANT_3MOIS
        , NB_POINT_EXPIRANT_6MOIS
        , STATUT_CARTE
        , TOTAL_POINT_CUMULE
        , NB_PARRAINAGE
    )
select distinct on (CARTE_FID_ID)
    CARTE_FID_ID
    , CONTACT_ID
    , NUM_CARTE_FID
    , now()
    , now()
    , DATE_CREATION_CARTE
    , CODE_MAGASIN_SAP
    , NB_POINT_EXPIRANT_3MOIS
    , NB_POINT_EXPIRANT_6MOIS
    , STATUT_CARTE
    , TOTAL_POINT_CUMULE
    , NB_PARRAINAGE
    from(
        select
            concat(dcf.CODE_MAGASIN_SAP,dcf.NUM_CARTE_FID) as CARTE_FID_ID
            , ac.contact_id
            , dcf.NUM_CARTE_FID
            , dcf.DATE_CREATION_CARTE
            , dcf.CODE_MAGASIN_SAP
            , dcf.NB_POINT_EXPIRANT_3MOIS
            , dcf.NB_POINT_EXPIRANT_6MOIS
            , dcf.STATUT_CARTE
            , dcf.TOTAL_POINT_CUMULE
            , dcf.NB_PARRAINAGE 
        from replication_tampon.diapason_carte_fidelite dcf 
        join marketing.associations_contacts ac
            on dcf.code_client = ac.source_contact_id
    ) as main_carte_fid;