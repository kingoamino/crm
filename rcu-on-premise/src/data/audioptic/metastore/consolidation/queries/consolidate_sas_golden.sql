-- Si un golden est modifié :
-- - il est inséré dans la table sas_contacts_golden (par Audioptic)

-- - il est ensuite inséré ou mis à jour (upsert) dans la table des contacts unitaires tel que son source_contact_id = golden_id

insert into marketing.contacts_unitaires (
    source_contact_id
    , source_date_creation
    , source_date_modification
    , source_creation
    , sexe
    , civilite
    , nom
    , prenom
    , date_naissance
    , adresse1
    , adresse2
    , adresse3
    , adresse4
    , codepostal
    , ville
    , pays
    , email
    , optin_email
    , tel_fixe
    , tel_mobile
    , optin_sms
)
select
    cast(contact_id as varchar)
    , source_date_creation
    , source_date_modification
    , source_creation
    , sexe
    , civilite
    , nom
    , prenom
    , date_naissance
    , adresse1
    , adresse2
    , adresse3
    , adresse4
    , codepostal
    , ville
    , pays
    , email
    , optin_email
    , tel_fixe
    , tel_mobile
    , optin_sms
from espace_travail.sas_contacts_golden
on conflict(source_contact_id, source_creation)
do update
  set source_contact_id = excluded.source_contact_id
    , source_date_creation = excluded.source_date_creation
    , source_date_modification = excluded.source_date_modification
    , source_creation = excluded.source_creation
    , sexe = excluded.sexe
    , civilite = excluded.civilite
    , nom = excluded.nom
    , prenom = excluded.prenom
    , date_naissance = excluded.date_naissance
    , adresse1 = excluded.adresse1
    , adresse2 = excluded.adresse2
    , adresse3 = excluded.adresse3
    , adresse4 = excluded.adresse4
    , codepostal = excluded.codepostal
    , ville = excluded.ville
    , pays = excluded.pays
    , email = excluded.email
    , optin_email = excluded.optin_email
    , tel_fixe = excluded.tel_fixe
    , tel_mobile = excluded.tel_mobile
    , optin_sms = excluded.optin_sms;

-- - une association est ajoutée tel que source_contact_id = golden_id et golden_id = golden_id

insert into marketing.associations_contacts (
    contact_id
    , source_contact_id
    , source_creation
    , date_creation
    , date_modification
)
select
    contact_id
    , cast(contact_id as varchar)
    , 'sas_golden'
    , now()
    , now()
from espace_travail.sas_contacts_golden
on conflict(source_contact_id, source_creation)
do nothing;
