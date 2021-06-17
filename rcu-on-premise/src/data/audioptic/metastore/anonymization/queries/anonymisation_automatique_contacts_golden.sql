update marketing.contacts_golden main_cg
set anonymise = true
    , date_anonymise = current_date
    , source_anonymise = 1
    , nom = encode(sha256(main_cg.nom::bytea), 'hex')
    , prenom = encode(sha256(main_cg.prenom::bytea), 'hex')
    , tel_mobile = encode(sha256(main_cg.tel_mobile::bytea), 'hex')
    , email = encode(sha256(main_cg.email::bytea), 'hex')
    , tel_fixe = encode(sha256(main_cg.tel_fixe::bytea), 'hex')
    , adresse1 = encode(sha256(main_cg.adresse1::bytea), 'hex')
    , adresse2 = encode(sha256(main_cg.adresse2::bytea), 'hex')
    , adresse3 = encode(sha256(main_cg.adresse3::bytea), 'hex')
    , adresse4 = encode(sha256(main_cg.adresse4::bytea), 'hex')
    , civilite = null
    , date_derniere_ordo = null
    , date_naissance = cast(concat('01/01/', cast(date_part('year', main_cg.date_naissance) as varchar)) as date)
from
    (
        select cg.contact_id
        from marketing.contacts_golden cg
        left join marketing.transactions t
        using(contact_id)
        left join (
            select contact_id
                , date_contact
            from marketing.historique_logs
            where clic = true
        ) as hl
        using(contact_id)
        where cg.anonymise = false or cg.anonymise is null
        group by cg.contact_id
        having (
            (
                count(distinct t.transaction_id) > 0
                and max(cast(t.date_transaction + interval '5 years' as date)) < current_date
            ) or (
                max(cast(hl.date_contact + interval '3 years' as date)) < current_date
            )
        )
    ) enriched_golden
where main_cg.contact_id = enriched_golden.contact_id
    and (anonymise = false or anonymise is null);
