insert into interface_db_marketing.historique_logs (LOG_ID, CONTACT_ID, DATE_CREATION, DATE_MODIFICATION, DIFFUSION_ID, DATE_CONTACT, STATUT, OUVERTURE, CLIC, DESABONNEMENT, CODE_MAGASIN_SAP, SEG_COURANTE_OPTIQUE, SEG_COURANTE_CONTACTO, SEG_COURANTE_GENERALE)
select hl.LOG_ID, hl.CONTACT_ID, now(), now(), hl.DIFFUSION_ID, hl.DATE_CONTACT, hl.STATUT, hl.OUVERTURE, hl.CLIC, hl.DESABONNEMENT, hl.CODE_MAGASIN_SAP, hl.SEG_COURANTE_OPTIQUE, hl.SEG_COURANTE_CONTACTO, hl.SEG_COURANTE_GENERALE from marketing.historique_logs hl;