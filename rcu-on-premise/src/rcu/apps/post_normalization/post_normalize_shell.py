import sys

sys.path.append("rcu-on-premise/src")

from core.postgresql import get_database_connection
from rcu.apps.core.decorators import time_it
from rcu.apps.core.utils import get_metadata


# Define client (project)
client = ''

# Define the metastore directory
metastore_dir = 'data/' + client + '/metastore/post_normalization/'

# Set up a PostgreSQL database connection
conn = get_database_connection(client)

# Load the metadata file listing the queries to execute
metadata = get_metadata(metastore_dir, 'info.json')

# Create a cursor to perform database operations
cur = conn.cursor()

# For each mapping create a dataframe and store it into frames
for query_file in metadata['queries']:
    sql_file = open(metastore_dir + 'queries/' + query_file, 'r')
    print(query_file)
    # Execute the SQL file
    try:
        cur.execute(sql_file.read())
    except Exception as e:
        conn.rollback()
        print('Error:', e)
        sys.exit(1)

# Commit the transactions
try:
    conn.commit()
except Exception as e:
    conn.rollback()
    print('Error:', e)
    sys.exit(1)
