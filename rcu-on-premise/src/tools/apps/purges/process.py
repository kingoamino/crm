import sys
import logging

from rcu.apps.core.utils import get_metadata
from tools.apps.purges.utils import (
    get_purge_config,
    get_purges_codes,
    purge_files_from_server
)


def execute_all_purges(client):
    """
    Executes all purges processes by retrieving all purges codes
    configured.
    """
    # Define the metastore directory
    metastore_dir = 'data/' + client + '/metastore/tools/purges/'

    # Load the metadata file describing the log messages
    logs = get_metadata(metastore_dir, 'logs.json')

    logging.info(logs['start'])

    for code in get_purges_codes(client):
        try:
            logging.info(logs['query_info'] + code)
            execute_purge(client, code)
        except Exception as e:
            logging.exception(logs['query_exception'] + code)

    logging.info(logs['end'])


def execute_purge(client, purge_code):
    """
    Executes a purge process of one or multiple directories for a specific
    client based on a purge configuration.

    Parameters
    ----------
    client : str
        The client the import will be executed for.

    purge_code : str
        Code associated to the purge to execute.
    """

    # Retrieve import configuration from import code
    purge_config = get_purge_config(client, purge_code)

    # Get the file from the remote server to a local path
    purge_files_from_server(client, purge_config)
