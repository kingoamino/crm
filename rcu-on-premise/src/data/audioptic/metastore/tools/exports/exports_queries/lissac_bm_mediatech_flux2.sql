select 
    CONTACT_ID
    , TRANSACTION_ID
    , CODE_MAGASIN_SAP
    , DATE_TRANSACTION
    , '' as COSIUM 
from marketing.transactions t 
where t.FACTURE_ANNULEE = false 
    and cast(DATE_TRANSACTION + interval '7 days' as date) >= current_date;