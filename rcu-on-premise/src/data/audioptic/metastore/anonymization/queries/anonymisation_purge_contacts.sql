delete
from marketing.segmentation
where contact_id in (
    select contact_id
    from marketing.contacts_golden
    where anonymise = true
        and cast(date_anonymise + interval '5 years' as date) < current_date
);

delete
from marketing.score_nps
where contact_id in (
    select contact_id
    from marketing.contacts_golden
    where anonymise = true
        and cast(date_anonymise + interval '5 years' as date) < current_date
);

delete
from marketing.historique_consentements
where contact_id in (
    select contact_id
    from marketing.contacts_golden
    where anonymise = true
        and cast(date_anonymise + interval '5 years' as date) < current_date
);

delete
from marketing.historique_logs
where contact_id in (
    select contact_id
    from marketing.contacts_golden
    where anonymise = true
        and cast(date_anonymise + interval '5 years' as date) < current_date
);

delete
from marketing.agregats_contacts
where contact_id in (
    select contact_id
    from marketing.contacts_golden
    where anonymise = true
        and cast(date_anonymise + interval '5 years' as date) < current_date
);

delete
from marketing.details_transactions dt
using marketing.contacts_golden cg
where anonymise = true
    and cast(date_anonymise + interval '5 years' as date) < current_date
    and dt.contact_id = cg.contact_id;

delete
from marketing.transactions t
using marketing.contacts_golden cg
where anonymise = true
    and cast(date_anonymise + interval '5 years' as date) < current_date
    and t.contact_id = cg.contact_id;

delete
from marketing.contacts_unitaires cu
using (
    select ac.source_contact_id
        , ac.source_creation
    from marketing.associations_contacts ac
    join marketing.contacts_golden cg
    using(contact_id)
    where anonymise = true
        and cast(date_anonymise + interval '5 years' as date) < current_date
) tmp
where (cu.source_contact_id, cu.source_creation) = (tmp.source_contact_id, tmp.source_creation);

delete
from marketing.associations_contacts
where contact_id in (
    select contact_id
    from marketing.contacts_golden
    where anonymise = true
        and cast(date_anonymise + interval '5 years' as date) < current_date
);

delete
from marketing.contacts_golden
where anonymise = true
    and cast(date_anonymise + interval '5 years' as date) < current_date;
