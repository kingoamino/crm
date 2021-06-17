import numpy as np
import pandas as pd
import logging

from datetime import datetime
from datetime import timedelta

from rcu.apps.core.utils import get_metadata
from rcu.apps.core.utils import upsert_from_df
from rcu.apps.normalization import norms


def import_process(metastore_dir, conn):
    """
    Imports data from multiple tables in the PostreSQL database,
    combines them, and returns the result in a unified schema dataframe.

    Parameters
    ----------
    metastore_dir : str
        The metastore directory.

    conn : psycopg2.extensions.connection
        The connection to the PostgreSQL database instance.
        It encapsulates the databasesession.

    Returns
    -------
    df : dataframe
        The result of combining multiple dataframes.
    """
    # Load the metadata file describing the log messages
    logs = get_metadata(metastore_dir, 'logs.json')
    logging.info(logs['import_process'])
    # Load the metadata file describing the import mappings from its location
    # in the metastore
    metadata = get_metadata(metastore_dir, 'import.json')
    # Initialize an empty dict to store dataframes
    frames = {}
    # For each mapping create a data frame and store it into frames
    for mapping in metadata['mappings']:
        # Get source and destination columns
        cols = [
            'cast({} as varchar) as {}' \
                .format(src, dst) for src, dst in mapping['cols']
        ]
        # Build the SQL query
        sql_query = 'SELECT {} FROM {}.{}' \
            .format(
                ', '.join(cols), mapping['table_schema'],mapping['table_name']
            )
        if mapping['import_filter']:
            sql_query += ' WHERE {};'.format(mapping['import_filter_condition'])
        else:
            sql_query += ';'
        # Execute the query and store the records in a dataframe
        frames[mapping['id']] = pd \
            .read_sql_query(sql_query, conn, coerce_float=False)
        # Add the source name column
        frames[mapping['id']]['src_name'] = mapping['src_name']
        # Keep only the records that have been modified within the last nb_days days
        nb_days = int(mapping['nb_days'])
        if nb_days:
            frames[mapping['id']] = frames[mapping['id']]
            [
                frames[mapping['id']]['src_updated_dt']
                >= str(datetime.now() - timedelta(days=nb_days))
            ]
    # Combine the dataframes resulting from previous operations
    df = pd.concat([frames[i] for i in frames], ignore_index=True, sort=False)
    df = df.where(df.notnull(), None)
    for i in range(1, len(frames) + 1):
        del frames[i]
    # Add a normalization datetime to each row
    df['normalized_dt'] = df.apply(lambda x: str(datetime.now()), axis=1)
    return df


def generic_norm_process(metastore_dir, df):
    """
    Applies the normalization process on the generic columns and returns
    the resulting dataframe.

    Parameters
    ----------
    metastore_dir : str
        The metastore directory.

    df : dataframe
        The result of the default normalization process.

    Returns
    -------
    df : dataframe
        The result of the generic normalization process.
    """
    # Load the metadata file describing the log messages
    logs = get_metadata(metastore_dir, 'logs.json')
    logging.info(logs['generic_norm_process'])
    # Load the metadata file from its location in the metastore describing the
    # columns to normalize
    metadata = get_metadata(metastore_dir, 'columns.json')
    # Get the columns to normalize
    norm_map = [md['norm_map'] for md in metadata['columns'] if md['norm_type'] == 'generic'][0]
    # Get the language
    lang = next(md['lang'] for md in metadata['columns'] if md['norm_type'] == 'generic')
    # Normalize each column and store the result in a new column "norm_*"
    for i in norm_map:
        if i['col'] == 'country':
            df['norm_' + i['col']] = df \
                .apply(lambda x: getattr(norms, i['func'])(x[i['col']], lang), axis=1)
        else:
            df['norm_' + i['col']] = df.apply(lambda x: getattr(norms, i['func'])(x[i['col']]), axis=1)
    return df


def phone_norm_process(metastore_dir, df):
    """
    Applies the normalization process on the phone columns and returns
    the resulting dataframe.

    Parameters
    ----------
    metastore_dir : str
        The metastore directory.
    df : dataframe
        The result of the generic normalization process.

    Returns
    -------
    df : dataframe
        The result of the phone normalization process.
    """
    # Load the metadata file describing the log messages
    logs = get_metadata(metastore_dir, 'logs.json')
    logging.info(logs['phone_norm_process'])
    # Load the metadata file from its location in the metastore
    metadata = get_metadata(metastore_dir, 'columns.json')
    # Get the columns to normalize
    norm_map = [md['norm_map'] for md in metadata['columns'] if md['norm_type'] == 'phone'][0]
    # Get the language
    lang = next(md['lang'] for md in metadata['columns'] if md['norm_type'] == 'phone')
    # Get the default country code
    country_code = next(
        md['country_code'] for md in metadata['columns'] if md['norm_type'] == 'phone'
    )
    # Normalize each column and store the result in a new column "norm_*"
    for i in norm_map:
        df['norm_' + i['col']] = df \
            .apply(
                lambda x: getattr(norms, i['func'])(x[i['col']], x['country'], lang, country_code),
                axis=1
            )
    # Put the phone and mobile phone numbers in the right order (phone, mobile
    # phone)
    df['tmp_phone'] = df \
        .apply(
            lambda x: norms.enrich_phone(
                ('' if x['norm_phone'] is None else x['norm_phone'])
                + '|' + ('' if x['norm_mobile_phone'] is None else x['norm_mobile_phone']),
                x['country'],
                lang,
                country_code),
                axis=1
        )
    # Put the phone and mobile phone numbers in their respective columns
    # New data frame with split value columns
    new_df = df['tmp_phone'].str.split('|', n = 1, expand = True)
    # Separate the normalized phone column with the new value
    df['norm_phone'] = new_df[0]
    # Reset the normalized mobile phone column with the new value
    df['norm_mobile_phone'] = new_df[1]
    # Drop the temporary column
    df.drop(columns=['tmp_phone'], inplace=True)
    return df


def validity_norm_process(metastore_dir, df):
    """
    Applies the validity process and returns the resulting dataframe.

    Parameters
    ----------
    metastore_dir : str
        The metastore directory.
    df : dataframe
        The result of the phone normalization process.

    Returns
    -------
    df : dataframe
        The result of the validity process.
    """
    # Load the metadata file describing the log messages
    logs = get_metadata(metastore_dir, 'logs.json')
    logging.info(logs['validity_norm_process'])
    # Load the metadata file from its location in the metastore
    metadata = get_metadata(metastore_dir, 'columns.json')
    # Get the columns to normalize
    norm_map = [
        md['norm_map'] for md in metadata['columns'] if md['norm_type'] == 'validity'
    ][0]
    # For each row, flag normalized columns valid if they contain values
    for i in norm_map:
        df['valid_' + i['col']] = df.apply(lambda x: getattr(norms, i['func'])(x[i['col']]), axis=1)
    return df


def norm_process(metastore_dir, df):
    """
    Execute all the normalization processes.

    Parameters
    ----------
    metastore_dir : str
        The metastore directory.
    df : dataframe
        The result of the import process.

    Returns
    -------
    df : dataframe
        The result of the whole normalization process.
    """
    # Execute the normalization process for the generic columns
    df = generic_norm_process(metastore_dir, df)
    # Execute the normalization process for the phone columns
    df = phone_norm_process(metastore_dir, df)
    # Execute the validity process
    df = validity_norm_process(metastore_dir, df)
    return df


def export_process(metastore_dir, conn, df):
    """
    Exports the result of the whole normalization process into the
    PostgreSQL database.

    Parameters
    ----------
    metastore_dir : str
        The metastore directory.
    conn : psycopg2.extensions.connection
        PostgreSQL database instance. It encapsulates the database
        session.
    df : dataframe
        The result of the whole normalization process.
    """
    # Load the metadata file describing the log messages
    logs = get_metadata(metastore_dir, 'logs.json')
    logging.info(logs['export_process'])
    # Load the metadata file from its location in the metastore
    metadata = get_metadata(metastore_dir, 'export.json')
    # Upsert
    upsert_from_df(
        df, conn, metadata['table_schema'], metadata['table_name'], metadata['mapping'],
        metadata['pk_cols'], metadata['update'], metadata['updated_dt_col'],
        metadata['distinct_from_clause'], metadata['update_filter'],
        metadata['update_filter_condition']
    )
