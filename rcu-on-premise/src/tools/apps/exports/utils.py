import csv
import pysftp
import sys

from datetime import datetime

from core.postgresql import get_database_connection

from rcu.apps.core.system import get_env_variable


def get_exports_codes(client):
    """
    Return all exports code configured.

    Parameters
    ----------
    client : str
        Current client's name.

    Returns
    -------
    codes : list
        List of all exports codes.
    """
    codes = []
    with open('data/' + client + '/metastore/tools/exports/exports.csv', newline='') as csvfile:
        reader = csv.DictReader(csvfile, delimiter=';')
        codes = [x['code'] for x in reader]
    return codes


def get_export_config(client, export_code):
    """
    Return export configuration from code given by opening the csv file
    containing the configuration of data to export.

    Parameters
    ----------
    client : str
        Current client's name.

    export_code : str
        Code of the export to process.

    Returns
    -------
    config : dict
        Contains export configuration.
    """
    config = None
    with open('data/' + client + '/metastore/tools/exports/exports.csv', newline='') as csvfile:
        reader = csv.DictReader(csvfile, delimiter=';')
        for row in reader:
            if row['code'] == export_code:
                config = row
                break
    return config


def export_file_from_database(client, export_config):
    """
    Export a file from a PostgreSQL database.
    TODO:

    Parameters
    ----------
    client : str
        Current client's name.

    export_config : dict
        Configuration of an export to execute.
    """
    try:
        # Open database connection as a with statement so everything
        # is executed as one transaction and will be commited in
        # case of no exception. Everything is rolled back if there
        # is an error with at least one file.

        file_query_path = 'data/{}/metastore/tools/exports/exports_queries/{}'.format(
            client,
            export_config['query_file']
        )

        with get_database_connection(client) as connection:
            with connection.cursor() as cursor:
                # Open the sql file and read the sql export query
                with open(file_query_path, 'r') as query_file:
                    export_sql_query = query_file.read()

                    # Create a temporary table
                    query = f'''
                        CREATE TEMPORARY TABLE
                            tmp_export_table
                        ON COMMIT DROP AS '''

                    # Load temp table with export fields and sql filter
                    query += export_sql_query;

                    cursor.execute(query)
                    now = datetime.now()


                    export_file_path = '/tmp/{}'.format(
                        export_config['file_mask'] + now.strftime('%Y%m%d_%H%M%S') + '.csv'
                    )

                    with open(export_file_path, 'w') as export_file:


                        copy_command = """\
                            COPY tmp_export_table TO STDOUT WITH CSV HEADER NULL '' DELIMITER '{}'\
                            """.format(
                            export_config['delimiter']
                        )

                        cursor.copy_expert(copy_command, export_file)

    except Exception as e:
        print('Error during loading file into db table:', e)
    finally:
        # Close database connection anyway
        if connection:
            connection.close()

        return export_file_path


def send_file(file_path, export_config):
    """
    Send a file to an FTP or SFTP server.
    TODO : Handling FTP and FTPs servers

    Parameters
    ----------
    file_path : str
        Path to the file to export.

    export_config : dict
        The export configuration for the file.
    """
    # If the server_type is SFTP
    if export_config['server_type'].lower() == 'sftp':
        # Disable the hostkey property
        cnopts = pysftp.CnOpts()
        cnopts.hostkeys = None

        # Get the sftp name
        sftp_name = export_config['server_name'].upper()

        # Creating the SFTP connection
        sftp = pysftp.Connection(
            host = get_env_variable(sftp_name + '_SFTP_HOST'),
            username = get_env_variable(sftp_name + '_SFTP_LOGIN'),
            password = get_env_variable(sftp_name + '_SFTP_PASSWORD'),
            port = int(get_env_variable(sftp_name + '_SFTP_PORT')),
            cnopts = cnopts
        )

        # Send the file to the remote server
        with sftp.cd(export_config['export_path']):
            sftp.put(file_path)

        # Closes the connection
        sftp.close()
