select 'Pas d''enregistrements avec purge = true dont le statut magasin n''est pas null' as test,
    case when count(*) = 0 then 'passed' else 'failed' end as result
from marketing.details_transactions dt
join marketing.magasins m
using(code_magasin_sap)
where dt.purge = true and m.statut is not null
union
select 'Pas d''enregistrements avec purge = false dont le statut magasin est null' as test,
    case when count(*) = 0 then 'passed' else 'failed' end as result
from marketing.details_transactions dt
join marketing.magasins m
using(code_magasin_sap)
where dt.purge = false and m.statut is null
union
select 'Pas d''enregistrements avec facture_annulee = true dont le numéro d''avoir n''est pas resneigné' as test,
    case when count(*) = 0 then 'passed' else 'failed' end as result
from marketing.details_transactions dt
join marketing.transactions t
using(transaction_id)
where dt.facture_annulee = true and (t.num_avoir is null or t.num_avoir = 0)
union
select 'Pas d''enregistrements avec facture_annulee = false dont le numéro d''avoir est resneigné' as test,
    case when count(*) = 0 then 'passed' else 'failed' end as result
from marketing.details_transactions dt
join marketing.transactions t
using(transaction_id)
where dt.facture_annulee = false and t.num_avoir is not null and t.num_avoir > 0
union
select 'Pas d''enregistrements avec type_transaction = 1 dont le numéro de facture est vide ou le numéro d''avoir est renseigné' as test,
    case when count(*) = 0 then 'passed' else 'failed' end as result
from marketing.details_transactions dt
join marketing.transactions t
using(transaction_id)
where dt.type_transaction = 1 and ((t.num_fact is null or t.num_fact = 0) or (t.num_avoir is not null and t.num_avoir > 0))
union
select 'Pas d''enregistrements avec type_transaction = 2 dont le numéro de facture est renseigné et le numéro d''avoir est vide' as test,
    case when count(*) = 0 then 'passed' else 'failed' end as result
from marketing.details_transactions dt
join marketing.transactions t
using(transaction_id)
where dt.type_transaction = 2 and t.num_fact is not null and t.num_fact > 0 and (t.num_avoir is null or t.num_avoir = 0)
union
select 'Le nombre d''enregistrement dans diapason_details_transactions liés à un contact et à un magasin = au nombre d''enregistrements dans details_transactions' as test,
    case when total_count = 0 then 'passed' else 'failed' end as result
from(
    select
        (
            select count(distinct(transaction_id, num_ligne)) as val1
            from
            (
                select *
                    , case
                        when num_avoir = 0 and num_fact > 0
                            then concat('F', cast(code_magasin_sap as varchar), cast(num_fact as varchar))
                            else concat('A', cast(code_magasin_sap as varchar), cast(num_avoir as varchar))
                    end as transaction_id
                from replication_tampon.diapason_details_transactions dt
                where exists(
                    select 1
                    from marketing.contacts_unitaires cu
                    where dt.code_client = cu.source_contact_id
                        and cu.source_creation = 'cosium'
                )
                and exists(
                    select 1
                    from marketing.magasins m
                    where dt.code_magasin_sap = m.code_magasin_sap
                )
            ) tmp
        ) - (
            select
                count(*) as val2
            from marketing.details_transactions
        ) as total_count
) as tc
union
select 'Pas d''enregistrements avec numéro d''avoir renseigné est id transaction différent de ''A'' + CODE_MAGASIN + NUM_AVOIR' as test,
    case when count(*) = 0 then 'passed' else 'failed' end as result
from marketing.details_transactions dt
join marketing.transactions t
using(transaction_id)
where t.num_avoir is not null and t.num_avoir > 0 and dt.transaction_id <> concat('A', dt.code_magasin_sap, t.num_avoir)
union
select 'Pas d''enregistrements avec numéro d''avoir vide est id transaction différent de ''F'' + CODE_MAGASIN + NUM_FACT' as test,
    case when count(*) = 0 then 'passed' else 'failed' end as result
from marketing.details_transactions dt
join marketing.transactions t
using(transaction_id)
where t.num_avoir = 0 and dt.transaction_id <> concat('F', dt.code_magasin_sap, t.num_fact)
order by test;
