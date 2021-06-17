import sys
import logging

from core.postgresql import get_database_connection
from rcu.apps.core.decorators import time_it
from rcu.apps.core.utils import get_metadata
from rcu.apps.normalization.process import *


@time_it
def execute_normalization(client):
    """
    Executes the normalization for a specific client (project).

    Parameters
    ----------
    client : str
        The client (project) the normalization will be executed for.
    """

    # Define the metastore directory
    metastore_dir = 'data/' + client + '/metastore/normalization/'

    # Load the metadata file describing the log messages
    logs = get_metadata(metastore_dir, 'logs.json')

    logging.info(logs['start'])

    # Set up a PostgreSQL database connection
    conn = get_database_connection(client)

    # Import the data to normalize from the database
    df = import_process(metastore_dir, conn)

    # Execute the whole normalization process
    df = norm_process(metastore_dir, df)

    # Export the normalization result into the database
    export_process(metastore_dir, conn, df)

    logging.info(logs['end'])
