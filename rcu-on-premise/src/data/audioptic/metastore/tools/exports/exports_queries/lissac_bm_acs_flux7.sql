select sn.CONTACT_ID, 
        sn.TRANSACTION_ID, 
        sn.URL_QUESTIONNAIRE, 
        sn.DATE_REPONSE, 
        t.DATE_CREATION, 
        t.DATE_MODIFICATION, 
        t.DATE_TRANSACTION, 
        t.CODE_MAGASIN_SAP, 
        sn.NOTE_1, sn.NOTE_2, 
        sn.NOTE_3, sn.NOTE_4, 
        sn.NOTE_5, sn.QUESTION_1, 
        sn.QUESTION_2, 
        sn.QUESTION_3
from marketing.score_nps sn
inner join marketing.transactions t using(TRANSACTION_ID)
where cast(sn.DATE_CREATION as date) = current_date;