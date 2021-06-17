import os
import sys
import logging

from rcu.apps.core.utils import get_metadata
from tools.apps.imports.utils import (
    get_import_config,
    get_import_ftp,
    load_file_to_dbtable,
    get_imports_codes,
    get_files_from_server
)


def execute_all_imports(client):
    """
    Executes all imports processes by retrieving all imports codes
    configured.
    """
    # Define the metastore directory
    metastore_dir = 'data/' + client + '/metastore/tools/imports/'

    # Load the metadata file describing the log messages
    logs = get_metadata(metastore_dir, 'logs.json')

    logging.info(logs['start'])

    for code in get_imports_codes(client):
        try:
            logging.info(logs['query_info'] + code)
            execute_import(client, code)
        except Exception as e:
            logging.exception(logs['query_exception'] + code)

    logging.info(logs['end'])


def execute_import(client, import_code):
    """
    Executes an import process of one or multiple files for a specific
    client based on a import configuration.

    Parameters
    ----------
    client : str
        The client the import will be executed for.

    import_code : str
        Code associated to the import to execute.
    """
    # Retrieve import configuration from import code
    import_config = get_import_config(client, import_code)

    # Get the files from the remote server to a local path
    file_path_list = get_files_from_server(client, import_config)

    # Load the file into the database
    for file_path in file_path_list:
        if file_path:
            load_file_to_dbtable(client, file_path, import_config)

        # Remove the file after it's been processed
        os.remove(file_path)
