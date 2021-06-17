import sys
import logging

from core.postgresql import get_database_connection
from rcu.apps.core.decorators import time_it
from rcu.apps.core.utils import get_metadata
from rcu.apps.deduplication.process import *


@time_it
def execute_deduplication(client):
    """
    Executes the deduplication for a specific client (project).

    Parameters
    ----------
    client : str
        The client (project) the deduplication will be executed for.
    """

    # Define the metastore directory
    metastore_dir = 'data/' + client + '/metastore/deduplication/'

    # Load the metadata file describing the log messages
    logs = get_metadata(metastore_dir, 'logs.json')

    logging.info(logs['start'])

    # Set up a PostgreSQL database connection
    conn = get_database_connection(client)

    # Import the tables used for the dudplication process from the database
    frames = import_process(metastore_dir, conn)

    # Execute the whole deduplication process
    frames = dedup_process(metastore_dir, frames)

    # Execute the whole merge process
    frames = merge_process(metastore_dir, frames)

    # Export the deduplication result into the database
    export_process(metastore_dir, conn, frames)

    logging.info(logs['end'])
