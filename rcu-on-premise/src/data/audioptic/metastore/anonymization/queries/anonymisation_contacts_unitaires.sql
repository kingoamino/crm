update marketing.contacts_unitaires cu
set anonymise = true
    , date_anonymise = current_date
    , source_anonymise = 1
    , nom = encode(sha256(cu.nom::bytea), 'hex')
    , prenom = encode(sha256(cu.prenom::bytea), 'hex')
    , tel_mobile = encode(sha256(cu.tel_mobile::bytea), 'hex')
    , tel_fixe = encode(sha256(cu.tel_fixe::bytea), 'hex')
    , email = encode(sha256(cu.email::bytea), 'hex')
    , adresse1 = encode(sha256(cu.adresse1::bytea), 'hex')
    , adresse2 = encode(sha256(cu.adresse2::bytea), 'hex')
    , adresse3 = encode(sha256(cu.adresse3::bytea), 'hex')
    , adresse4 = encode(sha256(cu.adresse4::bytea), 'hex')
    , civilite = null
    , date_derniere_ordo = null
    , date_naissance = cast(concat('01/01/', cast(date_part('year', cu.date_naissance) as varchar)) as date)
from
    (
        select ac.source_contact_id
            , ac.source_creation
        from marketing.associations_contacts ac
        join marketing.contacts_golden cg
        using(contact_id)
        where cg.anonymise = true
    ) tmp
where (cu.source_contact_id, cu.source_creation) = (tmp.source_contact_id, tmp.source_creation)
    and (cu.anonymise = false or cu.anonymise is null);