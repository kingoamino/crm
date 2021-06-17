import sys

sys.path.append("rcu-on-premise/src")

from core.postgresql import get_database_connection

from rcu.apps.normalization.process import *


# Define client (project)
client = ''

# Define the metastore directory
metastore_dir = 'data/' + client + '/metastore/normalization/'

# Set up a PostgreSQL database connection
conn = get_database_connection(client)

# Import the data to normalize from the database
df = import_process(metastore_dir, conn)

# Execute the whole normalization process
df = norm_process(metastore_dir, df)

# Export the normalization result into the database
export_process(metastore_dir, conn, df)
