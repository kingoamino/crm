insert into interface_db_marketing.segmentation (CONTACT_ID, SEG_PRECEDENTE_OPTIQUE, SEG_COURANTE_OPTIQUE, SEG_PRECEDENTE_CONTACTO, SEG_COURANTE_CONTACTO, SEG_PRECEDENTE_GENERALE, SEG_COURANTE_GENERALE)
select s.CONTACT_ID, s.SEG_PRECEDENTE_OPTIQUE, s.SEG_COURANTE_OPTIQUE, s.SEG_PRECEDENTE_CONTACTO, s.SEG_COURANTE_CONTACTO, s.SEG_PRECEDENTE_GENERALE, s.SEG_COURANTE_GENERALE from marketing.segmentation s;