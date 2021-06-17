import os
import sys
import logging

from rcu.apps.core.utils import get_metadata
from tools.apps.exports.utils import (
    export_file_from_database,
    get_export_config,
    get_exports_codes,
    send_file
)


def execute_all_exports(client):
    """
    Executes all exports processes by retrieving all export codes
    configured.
    """
    # Define the metastore directory
    metastore_dir = 'data/' + client + '/metastore/tools/exports/'

    # Load the metadata file describing the log messages
    logs = get_metadata(metastore_dir, 'logs.json')

    logging.info(logs['start'])

    for code in get_exports_codes(client):
        try:
            logging.info(logs['query_info'] + code)
            execute_export(client, code)
        except Exception as e:
            logging.exception(logs['query_exception'] + code)

    logging.info(logs['end'])


def execute_export(client, export_code):
    """
    Executes an export process of one query for a specific
    client based on an export configuration.

    Parameters
    ----------
    client : str
        The client the export will be executed for.

    export_code : str
        Code associated to the export to execute.
    """
    # Retrieve import configuration from import code
    export_config = get_export_config(client, export_code)

    # Export the file from the database and get the server
    file_path = export_file_from_database(client, export_config)

    if file_path:
        # remove empty double quotes
        os.system("""sed -i 's/""//g' """ + file_path)

        # Send the file to the remote server
        send_file(file_path, export_config)

        # remove the file
        os.remove(file_path)
