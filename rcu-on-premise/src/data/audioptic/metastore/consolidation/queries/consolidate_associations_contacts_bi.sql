insert into interface_db_marketing.associations_contacts (CONTACT_ID, SOURCE_CONTACT_ID, SOURCE_CREATION, DATE_CREATION, DATE_MODIFICATION)
select ac.CONTACT_ID, ac.SOURCE_CONTACT_ID, ac.SOURCE_CREATION, now(), now() from marketing.associations_contacts ac;