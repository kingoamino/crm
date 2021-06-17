import os


def get_env_variable(var_name):
    """
    Get the environment variable or return exception.
    """
    return os.environ[var_name]
