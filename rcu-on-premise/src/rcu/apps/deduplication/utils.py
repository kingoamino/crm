import pandas as pd
import numpy as np
import networkx as nx

from datetime import datetime
from datetime import timedelta
from uuid import uuid4


def get_edges(metadata, df, asso_df):
    """
    Builds and returns the graph edges where each edge connects a vertex (contact)
    to another vertex in the graph using a deduplication key.

    Parameters
    ----------
    metadata : JSON
        The JSON file content describing the deduplication keys.
    df : dataframe
        Contacts.
    asso_df : dataframe
        Contact associations.

    Returns
    -------
    edges : dataframe
        Connected contacts two by two.
    """
    # Define vertices by concatenating the source of the contact and its id
    df['vertex'] = df['src_name'].astype(str) + '|' + df['src_contact_id'].astype(str)
    # Define vertices by concatenating the source of the contact and its id
    asso_df['vertex'] = asso_df['src_name'] \
        .astype(str) + '|' + asso_df['src_contact_id'].astype(str)
    asso_df = asso_df[['vertex', 'master_id']]
    # For each contact, get current master id
    df = df \
        .merge(asso_df, on='vertex', how='left')
    # Initialize an empty dict to store dataframes
    frames = {}
    # For each deduplication key, find connected vertices (contacts) and assign
    # to each group a vertex that will connect them all
    # The result for each key is stored in a dataframe
    for key in metadata['keys']:
        df['tgt_vertex'] = df \
            .sort_values(metadata['order_by']) \
            .groupby(key['cols']) \
            .vertex \
            .transform('first') \
            .fillna(df['vertex'])
        frames[key['id']] = df[['vertex', 'tgt_vertex']].copy()
    # Combine all the resulting dataframes into one
    edges = pd \
        .concat([frames[i] for i in frames], ignore_index=True, sort=False) \
        .drop_duplicates()
    return edges


def get_connected_components(df):
    """
    Generates connected components and returns vertices with their
    components ids.

    Parameters
    ----------
    df : dataframe
        Graph edges.

    Returns
    -------
    df : dataframe
        Vertices with their component ids.
    """
    # Create a graph from the dataframe containing the edge list
    g = nx.from_pandas_edgelist(df, source='vertex', target='tgt_vertex')
    # Generate connected components
    connected_components = nx.connected_components(g)
    # Assign a component id to each vertex (vertices within the same component
    # get the same id)
    vertex_cid = {}
    for cid, component in enumerate(connected_components):
        for vertex in component:
            vertex_cid[vertex] = cid
    df = pd.DataFrame(list(vertex_cid.items()), columns=['vertex','component_id'])
    return df


def assign_master_id(df, frames):
    """
    Assign master ids and returns the updated associations.

    Parameters
    ----------
    df : dataframes
        Vertices (contacts) with their component ids.
    frames : dict
        Contacts, contact associations, and obsolete masters.

    Returns
    -------
    frames : dict
        Updated contacts, contact associations, and obsolete masters.
    """
    # Define vertices by concatenating the source of the contact and its id
    frames['asso']['vertex'] = frames['asso']['src_name'].astype(str) \
        + '|' + frames['asso']['src_contact_id'].astype(str)
    # For each vertex (contact), retrieve master id from current associations
    df = df \
        .merge(frames['asso'], on='vertex', how='left') \
        [['vertex', 'component_id', 'master_id', 'created_dt']]
    # Rename the master id column to old master id
    df.rename(columns={'master_id': 'old_master_id'}, inplace=True)
    # To each vertex within a component, assign the first master id of the
    # group and its creation date
    df['master_id'] = df \
        .sort_values('created_dt') \
        .groupby('component_id') \
        .old_master_id \
        .transform('first')
    df['created_dt'] = df \
        .sort_values('created_dt') \
        .groupby('component_id') \
        .created_dt \
        .transform('first')
    # Generate a master id to the new contacts
    new_df = df[df['master_id'].isnull()].copy()
    new_df = new_df \
        .groupby('component_id') \
        .agg(
            {
                'master_id': lambda x: str(uuid4()),
                'created_dt': lambda x: str(datetime.now())
            }
        ) \
        .reset_index() \
        [['component_id', 'master_id', 'created_dt']]
    # Assign the new generated master ids to the new contacts
    df = df \
        .merge(
            new_df,
            on='component_id',
            how='left',
            suffixes=('_left', '_right')
        )
    df['master_id'] = df.master_id_left.combine_first(df.master_id_right)
    df['created_dt'] = df.created_dt_left.combine_first(df.created_dt_right)
    # Find the new obsolete masters and merge them with the old ones
    new_obsolete_df = df[(df['old_master_id'].notnull())
        & (df['old_master_id'] != df['master_id'])][['old_master_id', 'master_id']]
    new_obsolete_df['created_dt'] = new_obsolete_df \
            .apply(lambda x: str(datetime.now()), axis=1)
    frames['obsolete'] = pd.concat([frames['obsolete'], new_obsolete_df], ignore_index=True,
        sort=False).drop_duplicates(subset=['old_master_id', 'master_id'], keep='first')
    # Add the master id columns to the contact dataframe
    frames['contact'] = frames['contact'] \
        .merge(
            df[['vertex', 'master_id', 'created_dt']],
            on='vertex'
        )
    # Get the current associations
    frames['asso'] = frames['contact'][['src_contact_id', 'src_name', 'master_id', 'created_dt']]
    return frames


def merge_contacts(metadata, df):
    """
    Merges contacts by taking logical groups of columns from each
    selected contact based on merge rules described in the metadata
    file.

    Parameters
    ----------
    metadata : JSON
        The JSON file content describing the deduplication keys.
    df : dataframe
        Contacts to merge.

    Returns
    -------
    df : dataframe
        Merged contacts.
    """
    # Add weight to each source
    df['weight'] = np.select(
        [df.src_name == x['name'] for x in metadata['sources']],
        [x['weight'] for x in metadata['sources']]
    )
    # Initialize an empty dict to store dataframes
    frames = {}
    for group in metadata['groups']:
        group['cols']
        # Add weight to each source
        df['filled_' + group['name'] + '_group'] = np.select(
            [df[group['cols']].isna().all(1)],
            [0],
            default=[1]
        )
        frames[group['name']] = df[df['filled_' + group['name'] + '_group'] == 1] \
            .sort_values(
                ['weight', metadata['order_by'][0], metadata['order_by'][1]],
                ascending=False
            ) \
            .groupby('master_id') \
            .first() \
            [group['cols']]
    df = pd \
        .concat([frames[i] for i in frames], axis=1) \
        .reset_index().rename(columns={'index': 'master_id'})
    df = df.where(df.notnull(), None)
    return df
