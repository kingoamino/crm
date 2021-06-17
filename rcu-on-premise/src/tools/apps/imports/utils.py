import csv
import sys

import pysftp

from datetime import datetime

from core.postgresql import get_database_connection

from rcu.apps.core.system import get_env_variable


def get_imports_codes(client):
    """
    Return all imports code configured.

    Parameters
    ----------
    client : str
        Current client's name.

    Returns
    -------
    codes : list
        List of all imports codes.
    """
    codes = []
    with open('data/' + client + '/metastore/tools/imports/imports.csv', newline='') as csvfile:
        reader = csv.DictReader(csvfile, delimiter=';')
        codes = [x['code'] for x in reader]
    return codes


def get_import_config(client, import_code):
    """
    Return import configuration from code given by opening the csv file
    containing the configuration of data to import.

    Parameters
    ----------
    client : str
        Current client's name.

    import_code : str
        Code of the import to process.

    Returns
    -------
    config : dict
        Contains import configuration.
    """
    config = None
    with open('data/' + client + '/metastore/tools/imports/imports.csv', newline='') as csvfile:
        reader = csv.DictReader(csvfile, delimiter=';')
        for row in reader:
            if row['code'] == import_code:
                config = row
                break
    return config


def get_import_ftp(ftp_name, file_path):
    """
    Return an ftp connection depending on ftp name given in parameter
    of an import.

    Parameters
    ----------
    ftp_name : str
        Name of the FTP to establish the connection.

    file_path : str
        Path in the FTP where to find files to import.

    Returns
    -------
    ftp : obj
        FTP_TLS object instance from ftplib.
    """
    return ftp_open_connection(
        host = get_env_variable(ftp_name.upper() + '_FTP_HOST'),
        port = get_env_variable(ftp_name.upper() + '_FTP_PORT'),
        login = get_env_variable(ftp_name.upper() + '_FTP_LOGIN'),
        password = get_env_variable(ftp_name.upper() + '_FTP_PASSWORD'),
        path = file_path,
        auth_method = 'tls-ftp'
    )


def load_file_to_dbtable(client, file_path, import_config):
    """
    Load a file as an upsert from it's path into a PostgreSQL database
    table defined in the import configuration.

    Parameters
    ----------
    client : str
        Current client's name.

    file_path : str
        Path of the file to load into the database table

    import_config : dict
        Configuration of an import to execute.
    """
    connection = None
    try:
        # Retrieve file to import written on disk
        with open(file_path, 'r', encoding=import_config['encoding']) as file:

            # Retrieve file columns
            reader = csv.reader(
                file,
                delimiter=import_config['delimiter']
            )

            columns = next(reader)

            print(columns)

            # Open database connection as a with statement so everything
            # is executed as one transaction and will be commited in
            # case of no exception. Everything is rolled back if there
            # is an error with at least one file.
            with get_database_connection(client) as connection:
                with connection.cursor() as cursor:

                    # Retrieve table's name to load files
                    table_name = import_config['schema'] + '.' + import_config['table']

                    # Create a temporary table with the same structure of
                    # the wanted table where we want to copy data.
                    tmp_table_name = 'tmp_' + import_config['table']
                    cursor.execute(
                        'CREATE TEMP TABLE ' + tmp_table_name + \
                        ' (LIKE ' + table_name + ');'
                    )

                    # Drop pk auto increment column to be able to insert values
                    # if pk is not given in the import file.
                    if len(import_config['pk'].split(',')) == 1 and import_config['pk'] not in columns:
                        cursor.execute(
                            'ALTER TABLE ' + tmp_table_name + ' \
                                DROP COLUMN ' + import_config['pk'] + ';'
                        )

                    # Execute copy from command to load file into tmp table
                    cursor.copy_from(
                        file,
                        tmp_table_name,
                        sep = import_config['delimiter'],
                        columns = columns,
                        null = ''
                    )

                    # Finally insert values from tmp table to destination table
                    query = '''
                            INSERT INTO {0}
                                ({1})
                            SELECT
                                {1}
                            FROM
                                {2}
                            '''.format(table_name, ','.join(columns), tmp_table_name)
                    # Add on conflict parameter if import is upsert type
                    if import_config['is_upsert'] == 'true':
                        query += '''
                                ON CONFLICT ({0}) DO UPDATE
                                SET
                                    ({1}) = ({2});
                                '''.format(
                                    import_config['pk'],
                                    ','.join(columns),
                                    ','.join(['EXCLUDED.' + x for x in columns])
                                )
                    cursor.execute(query)

    except Exception as e:
        print('Error during loading file into db table:', e)
    finally:
        # Close database connection anyway
        if connection:
            connection.close()


def get_files_from_server(client, import_config):
    """
    Get the files from the remote SFTP of FTP server.

    Parameters
    ----------
    client : str
        Name of the client.

    import_config : str
        Import configuration of the specific file.

    Returns
    -------
    file_path : list
        The local paths of the files after downloading them.
    """
    now = datetime.now()
    # Initializing the file_path
    file_path = None
    file_path_list = []
    # If the server_type is SFTP
    if import_config['server_type'].lower() == 'sftp':
        # Disable the hostkey property
        cnopts = pysftp.CnOpts()
        cnopts.hostkeys = None
        # Get the sftp name
        sftp_name = import_config['server_name'].upper()
        # Creating the SFTP connection
        sftp = pysftp.Connection(
            host = get_env_variable(sftp_name + '_SFTP_HOST'),
            username = get_env_variable(sftp_name + '_SFTP_LOGIN'),
            password = get_env_variable(sftp_name + '_SFTP_PASSWORD'),
            port = int(get_env_variable(sftp_name + '_SFTP_PORT')),
            cnopts = cnopts
        )
        # Get the import path
        import_path = import_config['file_path']
        # Add the time date suffix to the file mask
        if import_config['today'] == 'true':
            file_mask = import_config['file_mask'] + now.strftime('%Y%m%d')
        else:
            file_mask = import_config['file_mask']
        if sftp_path_exists(sftp, import_path):
            with sftp.cd(import_path):
                for f in sftp.listdir():
                    if f.startswith(file_mask):
                        file_path = '/tmp/' + f
                        sftp.get(f, file_path)
                        file_path_list.append(file_path)
                        if import_config['to_archive'] == 'true':
                            with sftp.cd('/'):
                                sftp.rename(
                                    import_path + '/' + f,
                                    (import_config['archive_path'] + '/' + f) \
                                        .replace(
                                            '.csv',
                                            datetime.now().strftime('_bkp_%Y%m%d%H%M%S') + '.csv'
                                        )
                                )
    # Closes the connection
    sftp.close()
    # Return the file_path
    return file_path_list

def sftp_path_exists(sftp, path):
    """
    Check if SFTP path exists.

    Parameters
    ----------
    sftp : obj
        SFTP connection obj.

    path : str
        Directory path.

    Returns
    -------
     : bool
        If path exists then True else False.
    """
    try:
        sftp.stat(path)
        return True
    except Exception as e:
        return False
