import csv
import sys
import time

import pysftp

from datetime import datetime, timedelta

from core.postgresql import get_database_connection

from rcu.apps.core.system import get_env_variable


# Defining the global variables
# These global variables are used in the callback functions of the
# sftp.walktree method
file_names = []
dir_names = []
un_name = []


def store_files_name(file_name):
    """
    Callback function in the sftp.walktree method to store filenames.

    Parameters
    ----------
    file_name : str
        The file name to store.
    """
    file_names.append(file_name)

def store_dir_name(dir_name):
    """
    Callback function in the sftp.walktree method to store directories.

    Parameters
    ----------
    dir_name : str
        The directory name to store.
    """
    dir_names.append(dir_name)


def store_other_file_types(file_name):
    """
    Callback function in the sftp.walktree method to store other file
    types filenames.

    Parameters
    ----------
    file_name : str
        The file name to store.
    """
    un_name.append(file_name)


def get_purges_codes(client):
    """
    Return all purges code configured.

    Parameters
    ----------
    client : str
        Current client's name.

    Returns
    -------
    codes : list
        List of all purges codes.
    """
    codes = []
    with open('data/' + client + '/metastore/tools/purges/purges.csv', newline='') as csvfile:
        reader = csv.DictReader(csvfile, delimiter=';')
        codes = [x['code'] for x in reader]
    return codes


def get_purge_config(client, purge_code):
    """
    Return purges configuration from code given by opening the csv file
    containing the configuration of data to purge.

    Parameters
    ----------
    client : str
        Current client's name.

    purge_code : str
        Code of the purges to process.

    Returns
    -------
    config : dict
        Contains purge configuration.
    """
    config = None
    with open('data/' + client + '/metastore/tools/purges/purges.csv', newline='') as csvfile:
        reader = csv.DictReader(csvfile, delimiter=';')
        for row in reader:
            if row['code'] == purge_code:
                config = row
                break
    return config


def purge_files_from_server(client, purge_config):
    """
    Purge files in the remote SFTP server.

    Parameters
    ----------
    client : str
        Name of the client.

    purge_config : str
        Purge configuration of the specific file.
    """
    now = datetime.now()

    # Get the maximum number of days of retention in the configuration
    retention_date = purge_config['retention_days']

    # Compute the posix time of the maximum retention days
    max_retention_date = now - timedelta(days=int(retention_date))
    posix_max_retention_date = time.mktime(max_retention_date.timetuple())

    # Reinitializing the global variables
    global file_names, dir_names, un_name
    file_names = []
    dir_names = []
    un_name = []

    # If the server_type is SFTP
    if purge_config['server_type'].lower() == 'sftp':
        # Disable the hostkey property
        cnopts = pysftp.CnOpts()
        cnopts.hostkeys = None

        # Get the sftp name
        sftp_name = purge_config['server_name'].upper()

        # Creating the SFTP connection
        sftp = pysftp.Connection(
            host = get_env_variable(sftp_name + '_SFTP_HOST'),
            username = get_env_variable(sftp_name + '_SFTP_LOGIN'),
            password = get_env_variable(sftp_name + '_SFTP_PASSWORD'),
            port = int(get_env_variable(sftp_name + '_SFTP_PORT')),
            cnopts = cnopts
        )

        # Get the purge path
        purge_path = purge_config['dir_path']

        is_recursive = True if purge_config['is_recursive'].lower() == 'true' else False

        # Listing the purge_path and storing the different file names
        # And directory names
        sftp.walktree(
            purge_path,
            store_files_name,
            store_dir_name,
            store_other_file_types,
            recurse=True
        )

        # If the file is outdated, delete it
        for f in file_names:
            file_utime = sftp.stat(f).st_atime
            if posix_max_retention_date > file_utime:
                sftp.remove(f)
                print(f + ' has been deleted from the server')

        # Closes the connection
        sftp.close()
