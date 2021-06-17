import sys
import logging

from core.postgresql import get_database_connection
from rcu.apps.core.decorators import time_it
from rcu.apps.core.utils import get_metadata


@time_it
def execute_consolidation(client):
    """
    Executes the consolidation for a specific client (project).

    Parameters
    ----------
    client : str
        The client (project) the consolidation will be executed for.
    """

    # Define the metastore directory
    metastore_dir = 'data/' + client + '/metastore/consolidation/'

    # Load the metadata file describing the log messages
    logs = get_metadata(metastore_dir, 'logs.json')

    logging.info(logs['start'])

    # Set up a PostgreSQL database connection
    conn = get_database_connection(client)

    # Load the metadata file listing the queries to execute
    metadata = get_metadata(metastore_dir, 'info.json')

    # Create a cursor to perform database operations
    cur = conn.cursor()

    # For each mapping create a dataframe and store it into frames
    for query_file in metadata['queries']:
        sql_file = open(metastore_dir + 'queries/' + query_file, 'r')
        # Execute the SQL file
        try:
            logging.info(logs['query_info'] + query_file)
            cur.execute(sql_file.read())
            conn.commit()
        except Exception as e:
            # conn.rollback()
            logging.exception(logs['query_exception'] + query_file)
            sys.exit(1)

    # Commit the transactions
    # try:
    #     conn.commit()
    # except Exception as e:
    #     conn.rollback()
    #     print('Error:', e)
    #     sys.exit(1)

    logging.info(logs['end'])
