update marketing.contacts_golden cg
set anonymise = true
    , date_anonymise = current_date
    , source_anonymise = 2
    , nom = encode(sha256(cg.nom::bytea), 'hex')
    , prenom = encode(sha256(cg.prenom::bytea), 'hex')
    , tel_mobile = encode(sha256(cg.tel_mobile::bytea), 'hex')
    , email = encode(sha256(cg.email::bytea), 'hex')
    , tel_fixe = encode(sha256(cg.tel_fixe::bytea), 'hex')
    , adresse1 = encode(sha256(cg.adresse1::bytea), 'hex')
    , adresse2 = encode(sha256(cg.adresse2::bytea), 'hex')
    , adresse3 = encode(sha256(cg.adresse3::bytea), 'hex')
    , adresse4 = encode(sha256(cg.adresse4::bytea), 'hex')
    , civilite = null
    , date_derniere_ordo = null
    , date_naissance = cast(concat('01/01/', cast(date_part('year', cg.date_naissance) as varchar)) as date)
from espace_travail.sas_anonymisation_cc sas
where cg.contact_id = sas.contact_id
    and (cg.anonymise = false or cg.anonymise is null);
