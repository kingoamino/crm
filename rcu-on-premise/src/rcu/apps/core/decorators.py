from functools import wraps
from time import time
import logging


def time_it(func):
    @wraps(func)
    def wrapper(*args, **kwargs):
        start = time()
        result = func(*args, **kwargs)
        end = time()
        logging.info('Durée : ' + str(int(end - start)) + ' secondes')
        return result
    return wrapper
