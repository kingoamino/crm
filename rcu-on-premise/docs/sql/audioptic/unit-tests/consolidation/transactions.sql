select 'Le nombre de transaction dans details_transactions = nombre d''enregistrements dans transactions' as test,
    case when total_count = 0 then 'passed' else 'failed' end as result
from(
    select
        (
            select
                count(distinct transaction_id) as val1
            from marketing.details_transactions
        ) - (
            select
                count(*) as val2
            from marketing.transactions
        ) as total_count
) as tc
union
select 'Pas d''enregistrements avec purge = true dont le statut magasin n''est pas null' as test,
    case when count(*) = 0 then 'passed' else 'failed' end as result
from marketing.transactions t
join marketing.magasins m
using(code_magasin_sap)
where t.purge = true and m.statut is not null
union
select 'Pas d''enregistrements avec purge = false dont le statut magasin est null' as test,
    case when count(*) = 0 then 'passed' else 'failed' end as result
from marketing.transactions t
join marketing.magasins m
using(code_magasin_sap)
where t.purge = false and m.statut is null
union
select 'Pas d''enregistrements avec facture_annulee = true dont le numéro d''avoir n''est pas resneigné' as test,
    case when count(*) = 0 then 'passed' else 'failed' end as result
from marketing.transactions
where facture_annulee = true and (num_avoir is null or num_avoir = 0)
union
select 'Pas d''enregistrements avec facture_annulee = false dont le numéro d''avoir est resneigné' as test,
    case when count(*) = 0 then 'passed' else 'failed' end as result
from marketing.transactions
where facture_annulee = false and num_avoir is not null and num_avoir > 0
union
select 'Pas d''enregistrements avec type_transaction = 1 dont le numéro de facture est vide ou le numéro d''avoir est renseigné' as test,
    case when count(*) = 0 then 'passed' else 'failed' end as result
from marketing.transactions
where type_transaction = 1 and ((num_fact is null or num_fact = 0) or (num_avoir is not null and num_avoir > 0))
union
select 'Pas d''enregistrements avec type_transaction = 2 dont le numéro de facture est renseigné et le numéro d''avoir est vide' as test,
    case when count(*) = 0 then 'passed' else 'failed' end as result
from marketing.transactions
where type_transaction = 2 and num_fact is not null and num_fact > 0 and (num_avoir is null or num_avoir = 0)
union
select 'Pas d''enregistrements avec numéro d''avoir renseigné est id transaction différent de ''A'' + CODE_MAGASIN + NUM_AVOIR' as test,
    case when count(*) = 0 then 'passed' else 'failed' end as result
from marketing.transactions
where num_avoir is not null and num_avoir > 0 and transaction_id <> concat('A', code_magasin_sap, num_avoir)
union
select 'Pas d''enregistrements avec numéro d''avoir vide est id transaction différent de ''F'' + CODE_MAGASIN + NUM_FACT' as test,
    case when count(*) = 0 then 'passed' else 'failed' end as result
from marketing.transactions
where num_avoir = 0 and transaction_id <> concat('F', code_magasin_sap, num_fact)
union
select 'Pas d''enregistrements avec acht_prog = true tel qu''il n''existe pas un code_geometrie = 3' as test,
    case when count(*) = 0 then 'passed' else 'failed' end as result
from marketing.transactions t
where t.acht_prog = true
    and not exists(
        select 1
        from marketing.details_transactions dt
        where t.transaction_id = dt.transaction_id
            and dt.code_geometrie = 3
    )
union
select 'Pas d''enregistrements avec acht_prog = false tel qu''il existe un code_geometrie = 3' as test,
    case when count(*) = 0 then 'passed' else 'failed' end as result
from marketing.transactions t
where t.acht_prog = false
    and exists(
        select 1
        from marketing.details_transactions dt
        where t.transaction_id = dt.transaction_id
            and dt.code_geometrie = 3
    )
union
select 'Pas d''enregistrements avec acht_unifocal = true tel qu''il n''existe pas un code_geometrie = 5' as test,
    case when count(*) = 0 then 'passed' else 'failed' end as result
from marketing.transactions t
where t.acht_unifocal = true
    and not exists(
        select 1
        from marketing.details_transactions dt
        where t.transaction_id = dt.transaction_id
            and dt.code_geometrie = 5
    )
union
select 'Pas d''enregistrements avec acht_unifocal = false tel qu''il existe un code_geometrie = 5' as test,
    case when count(*) = 0 then 'passed' else 'failed' end as result
from marketing.transactions t
where t.acht_unifocal = false
    and exists(
        select 1
        from marketing.details_transactions dt
        where t.transaction_id = dt.transaction_id
            and dt.code_geometrie = 5
    )
union
select 'Pas d''enregistrements avec acht_verre_autre = true tel qu''il n''existe pas un type_article in(''verre'', ''monture'')' as test,
    case when count(*) = 0 then 'passed' else 'failed' end as result
from marketing.transactions t
where t.acht_verre_autre = true
    and not exists(
        select 1
        from marketing.details_transactions dt
        where t.transaction_id = dt.transaction_id
            and lower(dt.type_article) in('verre', 'monture')
    )
union
select 'Pas d''enregistrements avec acht_verre_autre = false tel qu''il existe un type_article in(''verre'', ''monture'')' as test,
    case when count(*) = 0 then 'passed' else 'failed' end as result
from marketing.transactions t
where t.acht_verre_autre = false
    and exists(
        select 1
        from marketing.details_transactions dt
        where t.transaction_id = dt.transaction_id
            and lower(dt.type_article) in('verre', 'monture')
    )
union
select 'Pas d''enregistrements avec acht_lentille = true tel qu''il n''existe pas un type_article = ''lentille''' as test,
    case when count(*) = 0 then 'passed' else 'failed' end as result
from marketing.transactions t
where t.acht_lentille = true
    and not exists(
        select 1
        from marketing.details_transactions dt
        where t.transaction_id = dt.transaction_id
            and lower(dt.type_article) = 'lentille'
    )
union
select 'Pas d''enregistrements avec acht_lentille = false tel qu''il existe un type_article = ''lentille''' as test,
    case when count(*) = 0 then 'passed' else 'failed' end as result
from marketing.transactions t
where t.acht_lentille = false
    and exists(
        select 1
        from marketing.details_transactions dt
        where t.transaction_id = dt.transaction_id
            and lower(dt.type_article) = 'lentille'
    )
union
select 'Le nombre de transactions dans diapason_details_transactions liées à un contact et à un magasin = au nombre d''enregistrements dans transactions' as test,
    case when total_count = 0 then 'passed' else 'failed' end as result
from(
    select
        (
            select count(distinct transaction_id) as val1
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
            from marketing.transactions
        ) as total_count
) as tc
order by test;
