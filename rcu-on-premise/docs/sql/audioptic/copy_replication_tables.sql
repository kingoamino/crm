-- Exporting data from diapason_contacts_unitaires table to a CSV file
\copy (select * from replication_tampon.diapason_contacts_unitaires) TO '/home/user_crm/synkro_bdd/diapason_contacts_unitaires.csv' DELIMITER '|' CSV HEADER;
-- Exporting data from diapason_details_transactions table to a CSV file
\copy (select * from replication_tampon.diapason_details_transactions) TO '/home/user_crm/synkro_bdd/diapason_details_transactions.csv' DELIMITER '|' CSV HEADER;
-- Exporting data from diapason_prisme_magasins table to a CSV file
\copy (select * from replication_tampon.diapason_prisme_magasins) TO '/home/user_crm/synkro_bdd/diapason_prisme_magasins.csv' DELIMITER '|' CSV HEADER;