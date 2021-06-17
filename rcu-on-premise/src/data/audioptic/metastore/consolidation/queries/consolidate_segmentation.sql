-- Segmentation

insert into marketing.segmentation (CONTACT_ID, SEG_PRECEDENTE_OPTIQUE, SEG_COURANTE_OPTIQUE,SEG_PRECEDENTE_CONTACTO, SEG_COURANTE_CONTACTO, SEG_PRECEDENTE_GENERALE, SEG_COURANTE_GENERALE) 
select client_glob.contact_id,
--Segmentation calculé uniquement a partir des données de transactions : uniquement les clients sont affectés à un segment
	   seg_precedente.SEG_PRECEDENTE_OPTIQUE,
--fillna et selection de la seg_optique
case when seg_optique.SEG_OPTIQUE is null or seg_optique.SEG_OPTIQUE = '' then 'Non acheteurs Lunette'
else seg_optique.SEG_OPTIQUE end as SEG_OPTIQUE,
	   seg_precedente.SEG_PRECEDENTE_CONTACTO,
--fillna et selection de la seg_lentille
case when seg_lentille.SEG_LENTILLE is null or seg_lentille.SEG_LENTILLE = '' then 'Non acheteurs Lentilles'
else seg_lentille.SEG_LENTILLE end as SEG_LENTILLE,
		seg_precedente.SEG_PRECEDENTE_GENERALE,

-------------------------------------------------
------------- Segmentation Generale -------------
-------------------------------------------------
case when seg_lentille.SEG_LENTILLE is null and seg_optique.SEG_OPTIQUE is null then 'Indecis'
	 when seg_lentille.SEG_LENTILLE is null and seg_optique.SEG_OPTIQUE in ('Nouveaux a potentiel','Nouveaux Premium') then 'Nouveaux exclusifs optiques'
	 when seg_lentille.SEG_LENTILLE is null and seg_optique.SEG_OPTIQUE in ('Potentiels', 'Pepites') then 'Mature exclusif optique'
	 when seg_lentille.SEG_LENTILLE in ('Nouveaux a potentiel', 'Nouveaux Premium', 'Potentiels','Pepites') and seg_optique.SEG_OPTIQUE in ('Nouveaux a potentiel', 'Nouveaux Premium', 'Potentiels','Pepites') then 'Clients mixtes'
	 when seg_lentille.SEG_LENTILLE in ('Nouveaux a potentiel', 'Nouveaux Premium', 'Potentiels','Pepites') and seg_optique.SEG_OPTIQUE is null then 'Exclusifs lentilles'
	 when seg_lentille.SEG_LENTILLE in ('Nouveaux a potentiel', 'Nouveaux Premium', 'Potentiels','Pepites') and seg_optique.SEG_OPTIQUE in ('Abandonnistes','Inactifs') then 'Convertis'
	 when seg_lentille.SEG_LENTILLE in ('Abandonnistes','Inactifs') and seg_optique.SEG_OPTIQUE in ('Nouveaux a potentiel', 'Nouveaux Premium', 'Potentiels','Pepites') then 'Convertis'
	 when seg_lentille.SEG_LENTILLE in ('Abandonnistes','Inactifs') and seg_optique.SEG_OPTIQUE is null  then 'Endormis'
	 when seg_lentille.SEG_LENTILLE is null  and seg_optique.SEG_OPTIQUE in ('Abandonnistes','Inactifs') then 'Endormis'
	 when seg_lentille.SEG_LENTILLE in ('Abandonnistes','Inactifs') and seg_optique.SEG_OPTIQUE in ('Abandonnistes','Inactifs') then 'Endormis'
else 'To check' end as SEG_GENERALE

from
(select transactions.contact_id,
		MAX(transactions.date_transaction) as dern_achat,
		MIN(transactions.date_transaction) as prem_achat,
		round((date(now())-  MAX(transactions.date_transaction))/ (365.25/12)) as recence_achat,
		round((date(now())-  MIN(transactions.date_transaction))/ (365.25/12)) as anciennete_achat,
		sum(transactions.total_net_ttc) as ca_client
from marketing.transactions
group by transactions.contact_id) client_glob

LEFT JOIN

-------------------------------------------------
------------- Segmentation Optique --------------
-------------------------------------------------
(select contact_id,
--Regles d'affectations pour la segmentation optique
case when anciennete_achat <12 and ca_client <=400 then 'Nouveaux a potentiel'
	 when anciennete_achat <12 and ca_client >400 then 'Nouveaux Premium'
	 when anciennete_achat >=12 and ca_client <=600 and recence_achat < 24 then 'Potentiels'
	 when anciennete_achat >=12 and ca_client >600 and recence_achat < 24 then 'Pepites'
	 when anciennete_achat >=12 and recence_achat >=24 and recence_achat < 36 then 'Abandonnistes'
	 when anciennete_achat >=12 and recence_achat >= 36 then 'Inactifs'
else 'To check' end as SEG_OPTIQUE
from
--Creation des indicateurs pour les clients ayant acheté verre ou monture
(select transactions.contact_id,
		round((date(now())-  MAX(transactions.date_transaction))/ (365.25/12)) as recence_achat,
		round((date(now())-  MIN(transactions.date_transaction))/ (365.25/12)) as anciennete_achat,
		sum(transactions.total_net_ttc) as ca_client
from marketing.transactions
--Filtres sur les acheteurs de verre ou monture et les factures
where acht_verre_autre = 't' and type_transaction = 1
group by transactions.contact_id) as t1) seg_optique
ON client_glob.contact_id = seg_optique.contact_id

LEFT JOIN

-------------------------------------------------
------------- Segmentation Lentille -------------
-------------------------------------------------
(select contact_id,
--Regles d'affectations pour la segmentation lentille
case when anciennete_achat <10 and ca_client <=150 then 'Nouveaux a potentiel'
	 when anciennete_achat <10 and ca_client >150 then 'Nouveaux Premium'
	 when anciennete_achat >=10 and ca_client <=250 and recence_achat < 18 then 'Potentiels'
	 when anciennete_achat >=10 and ca_client >250 and recence_achat < 18 then 'Pepites'
	 when anciennete_achat >=10 and recence_achat >=18 and recence_achat < 24 then 'Abandonnistes'
	 when anciennete_achat >=10 and recence_achat >= 24 then 'Inactifs'
else 'To check' end as SEG_LENTILLE
from
(select transactions.contact_id,
		round((date(now())-  MAX(transactions.date_transaction))/ (365.25/12)) as recence_achat,
		round((date(now())-  MIN(transactions.date_transaction))/ (365.25/12)) as anciennete_achat,
		sum(transactions.total_net_ttc) as ca_client
from marketing.transactions
--Filtres sur les acheteurs de lentilles et les factures
where acht_lentille = 't' and type_transaction = 1
group by transactions.contact_id) as t2) seg_lentille
on client_glob.contact_id = seg_lentille.contact_id

LEFT JOIN

-------------------------------------------------
----------------- Seg precedente ----------------
-------------------------------------------------
--On recupere les 3 segmentations de la veille
(select histo_seg.contact_id,
		histo_seg.SEG_PRECEDENTE_OPTIQUE,
		histo_seg.SEG_PRECEDENTE_CONTACTO,
		histo_seg.SEG_PRECEDENTE_GENERALE
from espace_travail.histo_seg) seg_precedente
on client_glob.contact_id = seg_precedente.contact_id;

truncate table espace_travail.histo_seg;
--On rempli la table d'historisation de la seg avec les données du jour
insert into espace_travail.histo_seg (CONTACT_ID, SEG_PRECEDENTE_OPTIQUE, SEG_PRECEDENTE_CONTACTO, SEG_PRECEDENTE_GENERALE)
select contact_id, seg_courante_optique, seg_courante_contacto, seg_courante_generale from marketing.segmentation;
