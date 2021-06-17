import psycopg2
import sys

from rcu.apps.core.system import get_env_variable


def get_database_connection(client):
    """
    Return a PostgreSQL database connection.

    Parameters
    ----------
    client : str
        Current client's name.

    Returns
    -------
    conn : psycopg2.extensions.connection
        PostgreSQL database connection.
    """
    conn = None
    try:
        # Get database connection information from OS environment variables
        # depending on given client
        host = get_env_variable(client.upper() + '_DB_HOST')
        user = get_env_variable(client.upper() + '_DB_USER')
        password = get_env_variable(client.upper() + '_DB_PWD')
        db = get_env_variable(client.upper() + '_DB_NAME')
        # Consolidate database connection parameters
        pg_engine = "user='{}' password='{}' host='{}' dbname='{}'".format(user, password, host, db)
        # Establish a connection to the database
        conn = psycopg2.connect(pg_engine)
    except psycopg2.DatabaseError as e:
        sys.exit(1)
    return conn
