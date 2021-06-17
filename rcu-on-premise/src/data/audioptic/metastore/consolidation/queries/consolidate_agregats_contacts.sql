-- Calcul des agrégats

insert into marketing.agregats_contacts
    (
        contact_id
        , age
        , ltv
        , potentiel_futur_presbyte
        , mixeur
        , acheteur_36mois
        , acheteur_12mois
        , pm_progressifs
        , pm_verres_autres
        , nouveaux_non_repris
        , pm_unifocaux
        , pm_lentille
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
        , contactable_email
        , contactable_sms
        , contactable_courrier
    )
select contact_id
    , age
    , ltv
    , potentiel_futur_presbyte
    , mixeur
    , acheteur_36mois
    , acheteur_12mois
    , pm_progressifs
    , pm_verres_autres
    , nouveaux_non_repris
    , pm_unifocaux
    , pm_lentille
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
    , contactable_email
    , contactable_sms
    , contactable_courrier
from (
    select cg.contact_id
        , case
            when (date_part('year', age(cg.date_naissance))) < 0
                or (date_part('year', age(cg.date_naissance))) > 120
                or (date_part('year', age(cg.date_naissance))) is null
            then 999
            else date_part('year', age(cg.date_naissance))
            end as age
        , sum(t.total_net_ttc)
            filter (
                where t.facture_annulee = false
                and t.date_transaction >= cast(current_date - interval '5 years' as date)
            ) as ltv
        , case
            when date_part('year', age(cg.date_naissance)) >= 44
                and date_part('year', age(cg.date_naissance)) < 60
                and count(*) filter(
                    where t.type_transaction = 1
                        and t.facture_annulee = false
                        and t.acht_prog = true
                ) = 0
                and count(*) filter(
                    where t.type_transaction = 1
                        and t.facture_annulee = false
                ) > 0
            then true
            else false
            end as potentiel_futur_presbyte
        , 0 as mixeur
        , case
            when count(*)
            filter(
                where t.facture_annulee = false
                    and t.date_transaction >= cast(current_date - interval '36 months' as date)
            ) > 0
        then true
        else false
        end as acheteur_36mois
        , avg(t.total_net_ttc)
            filter (
                where t.facture_annulee = false
                    and acht_prog = true
                    and t.date_transaction >= cast(current_date - interval '36 months' as date)
            ) as pm_progressifs
        , avg(t.total_net_ttc)
            filter (
                where t.facture_annulee = false
                    and acht_verre_autre = true
                    and t.date_transaction >= cast(current_date - interval '36 months' as date)
            ) as pm_verres_autres
        , avg(t.total_net_ttc)
            filter (
                where t.facture_annulee = false
                    and acht_unifocal = true
                    and t.date_transaction >= cast(current_date - interval '36 months' as date)
            ) as pm_unifocaux
        , avg(t.total_net_ttc)
            filter (
                where t.facture_annulee = false
                    and acht_lentille = true
                    and t.date_transaction >= cast(current_date - interval '36 months' as date)
            ) as pm_lentille
        , case
            when cg.email_valid = true
                and cg.optin_email = true
            then true
            else false
            end as contactable_email
        , case
            when cg.mobile_valid = true
                and cg.optin_sms = true
            then true
            else false
            end as contactable_sms
        , case
            when cg.adresse_valid = true
                and cg.optin_courrier = true
            then true
            else false
            end as contactable_courrier
    from marketing.contacts_golden cg
    left join marketing.transactions t
    using(contact_id)
    group by cg.contact_id
) as agg1
left join (
    select contact_id
        , bool_or(nouveaux_non_repris) as nouveaux_non_repris
        , bool_or(acheteur_12mois) as acheteur_12mois
        , max(date_prem_acht_progressifs) as date_prem_acht_progressifs
        , max(date_dern_acht_progressifs) as date_dern_acht_progressifs
        , max(date_prem_acht_unifocaux) as date_prem_acht_unifocaux
        , max(date_dern_acht_unifocaux) as date_dern_acht_unifocaux
        , max(date_prem_acht_verre) as date_prem_acht_verre
        , max(date_dern_acht_verre) as date_dern_acht_verre
        , max(date_prem_acht_lentille) as date_prem_acht_lentille
        , max(date_dern_acht_lentille) as date_dern_acht_lentille
        , max(date_prem_acht_optic) as date_prem_acht_optic
        , max(date_dern_acht_optic) as date_dern_acht_optic
        , max(date_prem_acht) as date_prem_acht
        , max(date_dern_acht) as date_dern_acht
    from (
        select contact_id
            , case
                when min(t.date_transaction) over(
                        partition by cg.contact_id
                    ) >= cast(current_date - interval '12 months' as date)
                then true
                else false
            end as nouveaux_non_repris
            , case
                when max(t.date_transaction) over(
                        partition by cg.contact_id
                    ) >= cast(current_date - interval '12 months' as date)
                then true
                else false
            end as acheteur_12mois
            , min(t.date_transaction) filter(where t.acht_prog = true) over(partition by cg.contact_id) as date_prem_acht_progressifs
            , max(t.date_transaction) filter(where t.acht_prog = true) over(partition by cg.contact_id) as date_dern_acht_progressifs
            , min(t.date_transaction) filter(where t.acht_unifocal = true) over(partition by cg.contact_id) as date_prem_acht_unifocaux
            , max(t.date_transaction) filter(where t.acht_unifocal = true) over(partition by cg.contact_id) as date_dern_acht_unifocaux
            , min(t.date_transaction) filter(where t.acht_verre_autre = true or t.acht_unifocal = true or t.acht_prog = true) over(partition by cg.contact_id) as date_prem_acht_verre
            , max(t.date_transaction) filter(where t.acht_verre_autre = true or t.acht_unifocal = true or t.acht_prog = true) over(partition by cg.contact_id) as date_dern_acht_verre
            , min(t.date_transaction) filter(where t.acht_lentille = true) over(partition by cg.contact_id) as date_prem_acht_lentille
            , max(t.date_transaction) filter(where t.acht_lentille = true) over(partition by cg.contact_id) as date_dern_acht_lentille
            , min(t.date_transaction) filter(where t.acht_verre_autre = true or t.acht_unifocal = true or t.acht_prog = true or t.acht_lentille = true) over(partition by cg.contact_id) as date_prem_acht_optic
            , max(t.date_transaction) filter(where t.acht_verre_autre = true or t.acht_unifocal = true or t.acht_prog = true or t.acht_lentille = true) over(partition by cg.contact_id) as date_dern_acht_optic
            , min(t.date_transaction) over(partition by cg.contact_id) as date_prem_acht
            , max(t.date_transaction) over(partition by cg.contact_id) as date_dern_acht
        from marketing.contacts_golden cg
        left join marketing.transactions t
        using(contact_id)
        where t.type_transaction = 1
            and t.facture_annulee = false
    ) as agg_2
    group by contact_id
) as agg_3
using(contact_id);
