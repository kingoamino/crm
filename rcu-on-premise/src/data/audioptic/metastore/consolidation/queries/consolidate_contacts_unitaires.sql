-- Pour les pays non normalisés mettre à jour le champ code_pays par la valeur : 'non_norm'

update marketing.contacts_unitaires
set code_pays = 'non_norm'
where code_pays is null
    or trim(code_pays) = '';
