import pandas as pd
import numpy as np
import logging

from datetime import datetime
from datetime import timedelta
from uuid import uuid4

from rcu.apps.core.utils import get_metadata
from rcu.apps.core.utils import upsert_from_df
from rcu.apps.core.utils import truncate_table
from rcu.apps.core.utils import insert_from_df
from rcu.apps.core.utils import flush_from_df
from rcu.apps.deduplication.utils import *


def import_process(metastore_dir, conn):
    """
    Imports contacts and contact associations, from the PostreSQL
    database and returns the resulting dataframes in a dict.

    Parameters
    ----------
    metastore_dir : str
        The metastore directory.

    conn : psycopg2.extensions.connection
        The connection to the PostgreSQL database instance.
        It encapsulates the databasesession.

    Returns
    -------
    frames : dict
        The resulting dataframes.
    """
    # Load the metadata file describing the log messages
    logs = get_metadata(metastore_dir, 'logs.json')
    logging.info(logs['import_process'])
    # Load the metadata file describing the import mapping from its location in the metastore
    metadata = get_metadata(metastore_dir, 'import.json')
    frames = {}
    # For each mapping create a dataframe and store it into frames
    for mapping in metadata['mappings']:
        # Get source and destination columns
        cols = ['cast({} as varchar) as {}'.format(src, dst) for src, dst in mapping['cols']]
        # Build the SQL query
        sql_query = 'SELECT {} FROM {}.{};' \
            .format(', '.join(cols), mapping['table_schema'],mapping['table_name'])
        # Execute the query and store the records in a dataframe
        frames[mapping['type']] = pd \
            .read_sql_query(sql_query, conn, coerce_float=False) \
            .replace('', np.nan)
    return frames


def dedup_process(metastore_dir, frames):
    """
    Executes the core steps of the deduplication process.

    Parameters
    ----------
    metastore_dir : str
        The metastore directory.

    frames : dict
        Contacts and contact associations.

    Returns
    -------
    frames : dict
        The updated versions of the contacts and contact associations.
    """
    # Load the metadata file describing the log messages
    logs = get_metadata(metastore_dir, 'logs.json')
    logging.info(logs['dedup_process'])
    # Load the metadata file describing the deduplication keys
    metadata = get_metadata(metastore_dir, 'keys.json')
    # Get the graph edges, each edge connects a vertex (contact) to another
    # vertex in the graph
    df = get_edges(metadata, frames['contact'], frames['asso'])
    # Get the graph connected components (connected contacts) by paths (deduplication keys)
    df = get_connected_components(df)
    # Assign a master id to all vertices grouped by their component id
    frames = assign_master_id(df, frames)
    return frames


def merge_process(metastore_dir, frames):
    """
    Executes the merge process.

    Parameters
    ----------
    metastore_dir : str
        The metastore directory.

    frames : dict
        Contacts and contact associations.

    Returns
    -------
    frames : dict
        The updated versions of the contacts and contact associations.
    """
    # Load the metadata file describing the log messages
    logs = get_metadata(metastore_dir, 'logs.json')
    logging.info(logs['merge_process'])
    # Load the metadata file containing the merge info
    metadata = get_metadata(metastore_dir, 'merge.json')
    # Assign a master id to all vertices grouped by their component id
    frames['contact'] = merge_contacts(metadata, frames['contact'])
    return frames


def export_process(metastore_dir, conn, frames):
    """
    Exports the result of the whole deduplication process (masters and
    contact associations) into the PostgreSQL database.

    Parameters
    ----------
    metastore_dir : str
        The metastore directory.
    conn : psycopg2.extensions.connection
        The connection to the PostgreSQL database instance.
        It encapsulates the databasesession.
    frames : dict
        Masters and contact associations.
    """
    # Load the metadata file describing the log messages
    logs = get_metadata(metastore_dir, 'logs.json')
    logging.info(logs['export_process'])
    # Load the metadata file from its location in the metastore
    metadata = get_metadata(metastore_dir, 'export.json')
    # Execute each export
    for mapping in metadata['mappings']:
        frames[mapping['df']] = frames[mapping['df']] \
                .where(frames[mapping['df']].notnull(), None)
        if mapping['operation'] == 'upsert':
            upsert_from_df(
                frames[mapping['df']], conn, mapping['table_schema'], mapping['table_name'],
                mapping['mapping'], mapping['pk_cols'], mapping['update'],
                mapping['updated_dt_col'], mapping['distinct_from_clause'],
                mapping['update_filter'], mapping['update_filter_condition']
            )
        else:
            flush_from_df(
                frames[mapping['df']], conn, mapping['table_schema'], mapping['table_name'],
                mapping['mapping']
            )
