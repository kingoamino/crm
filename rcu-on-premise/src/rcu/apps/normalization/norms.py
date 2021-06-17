import re
import sys
import unicodedata
import phonenumbers
import iso3166

from phonenumbers.phonenumberutil import region_code_for_country_code
from country_list import countries_for_language


def norm_email(email):
    """
    Normalizes an email address.

    Parameters
    ----------
    email : str
        The email to normalize.

    Returns
    -------
    norm_email : str
        The normalized email.
    """
    norm_email = str(email)
    if norm_email:
        # Replaces accents with their closest ASCII equivalents
        norm_email = unicodedata.normalize('NFD', str(norm_email))
        norm_email = norm_email.encode('ascii', 'ignore').decode('utf8')
        # Transform all characters in lowercase
        norm_email = norm_email.lower()
        re_match_email = r"(^[_a-z0-9-]+(\.[_a-z0-9-]+)*@[a-z0-9-]+(\.[a-z0-9-]+)*(\.[a-z]{2,4})$)"
        if not re.match(re_match_email, norm_email):
            norm_email = ''
    return norm_email


def norm_last_name(last_name):
    """
    Normalizes a last name by uppercasing all the letters and removing
    special characters.

    Parameters
    ----------
    last_name : str
        The last name to normalize.

    Returns
    -------
    norm_last_name : str
        The normalized last name.
    """
    norm_last_name = str(last_name).strip()
    if norm_last_name:
        # Replace all " ' _ occurrences in the first name with -
        norm_last_name = replace_multiple(norm_last_name, ["'", '"'], '-')
        # Transform all characters in uppercase
        norm_last_name = norm_last_name.upper()
        # NFD : Canonical Decomposition, followed by Canonical Composition
        norm_last_name = unicodedata.normalize('NFD', str(norm_last_name))
        # Leaves only unstressed upper case letters, dashes characters and
        # spaces
        norm_last_name = ''.join(c for c in norm_last_name \
                                 if unicodedata.category(c) == 'Lu' or c in [' ', '-', '&'])
        if len(norm_last_name) < 2:
            return ''
    return norm_last_name


def norm_first_name(first_name):
    """
    Normalizes first name by uppercasing the first letter capital,
    lowercasing, and removing special characters.

    Parameters
    ----------
    first_name : str
        The first name to normalize.

    Returns
    -------
    norm_first_name : str
        The normalized first name.
    """
    norm_first_name = str(first_name).strip().lower()
    if norm_first_name:
        if norm_first_name.find('-') == 0:
            return ''
        # Replace all " ' _ occurrences in the first name with -
        norm_first_name = replace_multiple(norm_first_name, ['"', "'"], '-')
        # We properly separate all names, whether it's a double name or a
        # middle name
        names = norm_first_name.replace('-', ' ').split()
        for name in names:
            # NFD : Canonical Decomposition, followed by Canonical Composition
            first_letter = unicodedata.normalize('NFD', str(name[:1])).upper()
            # Leaves only unstressed lower case letters and '&' character
            first_letter = ''.join(c for c in first_letter \
                                if unicodedata.category(c) == 'Lu' or c == '&').lower()
            # Leaves only unstressed lower case letters, '&' characters dashes
            # and spaces
            name_rest = ''.join(c for c in name[1:] \
                                if unicodedata.category(c) == 'Ll' or c in [' ', '-', '&'])
            norm_name = str(first_letter + name_rest)
            # We're using replace in order to keep spaces or dashes in the name
            norm_first_name = norm_first_name.replace(name, norm_name)
        # Transforms all first letters into capital
        norm_first_name = norm_first_name.title()
        if len(norm_first_name) < 2:
            return ''
    return norm_first_name


def norm_phone(phone, country, lang=None, country_code=None):
    """
    Returns phone number normalized in E164 international format using
    phonenumbers lib that is a third party librairy based on Google
    official phone numbers internal normalization project.

    Parameters
    ----------
    phone : str
        The phone number to normalize.
    country : str
        The country name to normalize.
    lang : str
        The language in which the country name is.
    country_code : str
        The default country code.

    Returns
    -------
    country : str
        The normalized country code.
    """
    norm_phone = None
    if country_code:
        country = country_code
    else:
        # Normalize the given country
        country = norm_country(country, lang)
    try:
        x = phonenumbers.parse(phone, country.upper())
        if phonenumbers.is_valid_number(x):
            # Retrieve detected country code from parsed number
            detected_country = region_code_for_country_code(x.country_code)
            # Try to format number only detected country match with
            # given country
            if detected_country == country.upper():
                norm_phone = phonenumbers.format_number(x, phonenumbers.PhoneNumberFormat.E164)
    except Exception:
        pass
    return norm_phone


def norm_country(country, lang=None):
    """
    Replaces a multiple substrings with a new substring.

    Parameters
    ----------
    country : str
        The country name to normalize.
    lang : str
        The language in which the country name is.

    Returns
    -------
    country : str
        The country code resulting of the normalization.
    """
    country = str(country)
    try:
        norm_country = iso3166.countries.get(country)
        norm_country = norm_country.alpha2
    except:
        try:
            countries = dict(countries_for_language(lang))
            countries = {v: k for k, v in countries.items()}
            norm_country = countries.get(country)
        except:
            norm_country = ''
    finally:
        return norm_country


def enrich_phone(phones, country, lang=None, country_code=None):
    """
    Returns given normalized phones enriched by replace them in
    corresponding orders : phone or mobile phone depending on
    given country code.
    This function deals with cases where one or two phones are given and
    try to replace in correct orders.
    Given phones are supposed to be normalized, this function does not
    verify given phone normalization.
    If no correct case is found, it returns phones like it was given.

    Parameters
    ----------
    phones : str
        One or multiple phones delimited with a pipe. Only one or two
        phones are allowed.
        Examples :
            * "+33645104788|+33147502310"
            * "|+33150457899"
            * "+33641021147|"
    country : str
        Country code to know what prefix is used for phone and mobile
        phone for given phones.
    lang : str
        The language in which the country name is.
    country_code : str
        The default country code.

    Returns
    -------
    result : str
        Phones concatenated in correct orders when possible or phones
        like it was given if enrichment was not possible.
        Examples :
            * "+33147502310|+33645104788"
            * "+33150457899|"
            * "|+33641021147"

    """
    if country_code:
        country = country_code
    else:
        # Normalize the given country
        country = norm_country(country, lang)
    # By default, return phones like it was given
    result = phones
    # Define all prefixes for phones and mobile phones by treated countries
    prefixes = {
        'FR': {
            'mobile_phone': ['+336', '+337'],
            'phone': ['+331', '+332', '+333', '+334', '+335']
        }
    }
    phones = phones.split('|')
    # Only process if given country is processed and if
    # given phones parameter is one or two splited phones
    if prefixes.get(country) and (len(phones) == 1 or len(phones) == 2):
        first_phone = phones[0]
        second_phone = phones[1] if len(phones) == 2 else ''
        # If first and second phones are mobile phones, do nothing
        if first_phone[:4] in prefixes[country]['mobile_phone'] and \
           second_phone[:4] in prefixes[country]['mobile_phone']:
            return result
        # If first and second phones are phones, do nothing
        if first_phone[:4] in prefixes[country]['phone'] and \
            second_phone[:4] in prefixes[country]['phone']:
            return result
        # If first phone number is mobile phone or second phone number is
        # phone, return replaced phones orders
        if first_phone[:4] in prefixes[country]['mobile_phone'] or \
           second_phone[:4] in prefixes[country]['phone']:
            result = second_phone + '|' + first_phone
    return result


def replace_multiple(string, to_be_replaced, replace_with):
    """
    Replaces a multiple substrings with a new substring.

    Parameters
    ----------
    string : str
        The current string.
    to_be_replaced : str
        The substring to replace.
    replace_with : str
        The new substring.

    Returns
    -------
    string : str
        The new string.
    """
    # Iterate over the strings to be replaced
    for elem in to_be_replaced:
        # Check if string is in the main string
        if elem in string:
            # Replace the string
            string = string.replace(elem, replace_with)
    return string


def is_valid(string):
    """
    Tests whether a string is valid (not empty) or not (empty).

    Parameters
    ----------
    string : str
        The string to test the validity.

    Returns
    -------
    True or False : str
        'False' if the string is empty, 'True' if it's not.
    """
    if string:
        return 'True'
    else:
        return 'False'
