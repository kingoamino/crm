import sys

sys.path.append("rcu-on-premise/src")

from core.postgresql import get_database_connection

from rcu.apps.deduplication.process import *


# Define client (project)
client = ''

# Define the metastore directory
metastore_dir = 'data/' + client + '/metastore/deduplication/'

# Set up a PostgreSQL database connection
conn = get_database_connection(client)

# Import the tables used for the dudplication process from the database
frames = import_process(metastore_dir, conn)

# Execute the whole deduplication process
frames = dedup_process(metastore_dir, frames)

# Export the deduplication result into the database
export_process(metastore_dir, conn, frames)
