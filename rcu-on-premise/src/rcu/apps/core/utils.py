import json


def load_json_file(file_path):
    """
    Loads a JSON file from its location and returns its content.

    Parameters
    ----------
    file_name : str
        The name of the file to load in.

    Returns
    -------
    metadata : JSON data
        The JSON file content.
    """
    with open(file_path) as json_file:
        data = json.load(json_file)
    return data


def get_metadata(metastore_dir, file_name):
    """
    Loads a JSON metadata file from its location in the metastore
    and returns the result.

    Parameters
    ----------
    metastore_dir : str
        The path to the metastore directory.
    file_name : str
        The name of the file to load in.

    Returns
    -------
    metadata : JSON
        The JSON file content.
    """
    # Define the path pointing the metastore file
    file_path = metastore_dir + file_name
    # Load the metastore file
    metadata = load_json_file(file_path)
    return metadata


def upsert_from_df(
        df, conn, table_schema, table_name, mapping, pk_cols,
        update, updated_dt_col, is_distinct_from, update_filter,
        update_filter_condition):
    """
    Upserts or inserts data from a dataframe into a PostgreSQL table.

    Parameters
    ----------
    df : dataframe
        The dataframe to upsert from.
    conn : psycopg2.extensions.connection
        The connection to the PostgreSQL database instance.
        It encapsulates the databasesession.
    table_schema : str
        The schema of the table to upsert into.
    table_name : str
        The table to upsert into.
    mapping : dict
        Mapping of source and destination columns.
    pk_cols : list
        Conflict target.
    update : bool
        Whether it's an upsert or an insert. 1 : upsert, 0 : insert.
    updated_dt_col : str
        Datetime column to update in case of update.
    is_distinct_from : bool
        Whether any source value for a column is different than its
        target value.
    update_filter : bool
        Whether the table to be updated should be filtered or not.
    update_filter_condition : str
        The filter condition to apply on the table to be updated.
    """
    # For each mapping create a dataframe and store it into frames
    # Get source columns
    src_cols = [cols[0] for cols in mapping]
    # Get destination columns
    dst_cols = [cols[1] for cols in mapping]
    # Get formatted destination columns for the insert part
    insert_dst_cols = ', '.join(dst_cols)
    # Get formatted destination placeholders for the insert part
    insert_dst_placeholders = ', '.join(['%({})s'.format(c) for c in dst_cols])
    # Get formatted primary key columns
    pk_cols = ', '.join(['{}'.format(c) for c in pk_cols])
    if update:
        # Get formatted destination columns for the update part
        update_dst_cols = ', '.join(
            [
                '{0} = coalesce(excluded.{0}, {1}.{0})'.format(c, table_name)
                for c in dst_cols
            ]
        ) + ', ' + updated_dt_col + ' = now()'
        # Prepare the SQL query
        conflict_action = 'DO UPDATE SET {}'.format(update_dst_cols)
        if is_distinct_from & update_filter:
            # Prepare the WHERE clause
            where_clause = ' WHERE ({})' \
                .format(update_filter_condition) \
                + ' AND ({})' \
                .format(', '.join([table_name + '.' + c for c in dst_cols])) \
                + ' IS DISTINCT FROM ' \
                + '({})'.format(', '.join(['excluded.' + c for c in dst_cols])) \
                + ';'
        elif is_distinct_from:
            # Prepare the WHERE clause
            where_clause = ' WHERE ({})' \
                .format(', '.join([table_name + '.' + c for c in dst_cols])) \
                + ' IS DISTINCT FROM ' \
                + '({})'.format(', '.join(['excluded.' + c for c in dst_cols])) \
                + ';'
        elif update_filter:
            # Prepare the WHERE clause
            where_clause = ' WHERE ({})' \
                .format(update_filter_condition) \
                + ';'
        else:
            where_clause = ';'
    else:
        # Prepare the SQL query
        conflict_action = 'DO NOTHING'
        where_clause = ';'
    # Create a cursor to perform database operations
    cur = conn.cursor()
    # Inserting each row
    for i in df.index:
        sql_query = 'INSERT INTO {}.{} ({}) VALUES ({}) ON CONFLICT ({}) ' \
            .format(
                table_schema, table_name, insert_dst_cols,
                insert_dst_placeholders, pk_cols
            ) \
            + conflict_action \
            + where_clause
        # Execute the SQL query
        cur.execute(
            sql_query,
            dict(zip(dst_cols, [df[x][i] for x in src_cols]))
        )
    # Commit pending transactions
    conn.commit()


def truncate_table(conn, table_schema, table_name):
    """
    Truncates a PostgreSQL table.

    Parameters
    ----------
    conn : psycopg2.extensions.connection
        The connection to the PostgreSQL database instance.
        It encapsulates the databasesession.
    table_schema : str
        The schema of the table to truncate.
    table_name : str
        The table to truncate.
    """
    # Create a cursor to perform database operations
    cur = conn.cursor()
    # Build the query to truncate the target table
    sql_query = 'TRUNCATE TABLE {}.{} CASCADE;' \
        .format(table_schema, table_name)
    # Truncate the target table
    cur.execute(sql_query)
    # Commit the transaction
    conn.commit()


def insert_from_df(df, conn, table_schema, table_name, mapping):
    """
    Inserts data from a dataframe into a PostgreSQL table.

    Parameters
    ----------
    df : dataframe
        The dataframe to insert from.
    conn : psycopg2.extensions.connection
        The connection to the PostgreSQL database instance.
        It encapsulates the databasesession.
    table_schema : str
        The schema of the table to insert into.
    table_name : str
        The table to insert into.
    mapping : dict
        Mapping of source and destination columns.
    """
    # For each mapping create a dataframe and store it into frames
    # Get source columns
    src_cols = [cols[0] for cols in mapping]
    # Get destination columns
    dst_cols = [cols[1] for cols in mapping]
    # Get formatted destination columns for the insert part
    insert_dst_cols = ', '.join(dst_cols)
    # Get formatted destination placeholders for the insert part
    insert_dst_placeholders = ', '.join(['%({})s'.format(c) for c in dst_cols])
    # Create a cursor to perform database operations
    cur = conn.cursor()
    # Inserting each row
    for i in df.index:
        sql_query = 'INSERT INTO {}.{} ({}) VALUES ({});' \
            .format(table_schema, table_name, insert_dst_cols, insert_dst_placeholders)
        # Execute the SQL query
        cur.execute(
            sql_query,
            dict(zip(dst_cols, [df[x][i] for x in src_cols]))
        )
    # Commit pending transactions
    conn.commit()


def flush_from_df(df, conn, table_schema, table_name, mapping):
    """
    Truncates a target PostgreSQL table and inserts data from a
    dataframe into it.

    Parameters
    ----------
    df : dataframe
        The dataframe to insert from.
    conn : psycopg2.extensions.connection
        The connection to the PostgreSQL database instance.
        It encapsulates the databasesession.
    table_schema : str
        The schema of the table to insert into.
    table_name : str
        The table to insert into.
    mapping : dict
        Mapping of source and destination columns.
    """
    # Truncate the target table
    truncate_table(conn, table_schema, table_name)
    # Inserting each row
    insert_from_df(df, conn, table_schema, table_name, mapping)
