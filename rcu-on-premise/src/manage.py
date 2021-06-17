import sys
import logging
import logging.config

from datetime import datetime

from rcu.apps.core.utils import get_metadata
from rcu.apps.consolidation.consolidate import execute_consolidation
from rcu.apps.deduplication.deduplicate import execute_deduplication
from rcu.apps.normalization.normalize import execute_normalization
from rcu.apps.post_normalization.post_normalize import execute_post_normalization
from rcu.apps.anonymization.anonymize import execute_anonymization

from tools.apps.imports.process import execute_import, execute_all_imports
from tools.apps.exports.process import execute_export, execute_all_exports
from tools.apps.purges.process import execute_purge, execute_all_purges


if __name__ == '__main__':

    # Retrieve current command to execute and module to process
    command = sys.argv[1]

    # Retrieve current client
    client = sys.argv[2]

    # Load the metadata file describing the logging configuration into a dictionary
    logging_config = get_metadata('data/' + client + '/metastore/logging/', 'config.json')

    # Take the logging configuration from the dictionary
    logging.config.dictConfig(logging_config)

    # Execute the normalization process
    if command == 'normalize':
        execute_normalization(client)

    # Execute the post-normalization process
    elif command == 'post_normalize':
        execute_post_normalization(client)

    # Execute the deduplication process
    elif command == 'deduplicate':
        execute_deduplication(client)

    # Execute the consolidation process
    elif command == 'consolidate':
        execute_consolidation(client)

    # Execute one import file process
    elif command == 'import':
        # Retrieve import code to execute
        import_code = sys.argv[3]
        execute_import(client, import_code)

    # Execute all imports file process
    elif command == 'import-all':
        execute_all_imports(client)

    # Execute one export file process
    elif command == 'export':
        # Retrieve import code to execute
        import_code = sys.argv[3]
        execute_export(client, import_code)

    # Execute all exports file process
    elif command == 'export-all':
        execute_all_exports(client)

    # Execute one purge file process
    elif command == 'purge':
        # Retrieve purge code to execute
        purge_code = sys.argv[3]
        execute_purge(client, purge_code)

    # Execute all purges processes
    elif command == 'purge-all':
        execute_all_purges(client)

    # Execute anonymization process
    elif command == 'anonymize':
        execute_anonymization(client)

    # Excute all processes
    elif command == 'run-all':

        # Execute all imports file process
        try:
            execute_all_imports(client)
        except Exception as e:
            logging.exception(e)

        try:
            # Execute the normalization process
            execute_normalization(client)
            # Execute the post-normalization process
            execute_post_normalization(client)
            # Execute the deduplication process
            execute_deduplication(client)
            # Execute the consolidation process
            execute_consolidation(client)
            # Execute the anonymization process
            execute_anonymization(client)
            # Execute all exports
            execute_all_exports(client)
        except Exception as e:
            logging.exception(e)

        # Execute all purges
        try:
            execute_all_purges(client)
        except Exception as e:
            logging.exception(e)

    # Given command does not exist
    else:
        print('Error: given command does not exist..')
