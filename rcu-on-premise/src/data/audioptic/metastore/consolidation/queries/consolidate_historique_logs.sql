-- Alimentation de l'historique des logs de diffusion

insert into marketing.historique_logs
    (
        log_id
        , contact_id
        , diffusion_id
        , date_contact
        , statut
        , ouverture
        , clic
        , desabonnement
        , seg_courante_optique
        , seg_courante_contacto
        , seg_courante_generale
        , code_magasin_sap
    )
select log_id
    , contact_id
    , diffusion_id
    , date_contact
    , statut
    , ouverture
    , clic
    , desabonnement
    , seg_courante_optique
    , seg_courante_contacto
    , seg_courante_generale
    , code_magasin_sap
from (
    select slda.log_id
        , coalesce(hg.contact_id, slda.contact_id) as contact_id
        , slda.diffusion_id
        , slda.date_contact
        , slda.statut
        , slda.ouverture
        , slda.clic
        , slda.desabonnement
        , slda.seg_courante_optique
        , slda.seg_courante_contacto
        , slda.seg_courante_generale
        , slda.code_magasin_sap
        , row_number() over(
            partition by slda.log_id
            order by slda.updated_dt
        ) as rn
    from espace_travail.sas_logs_diffusions_acs slda
    left join marketing.historique_golden hg
    using(contact_id)
) as tab
where rn = 1;
