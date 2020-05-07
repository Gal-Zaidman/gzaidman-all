import logging

def debug_decor(f):
    logger = logging.getLogger(f.__module__)
    def debug_wrapper(*args, **kwargs):
        logger.debug('{f.__name__} was called with args: {args} and kwargs {kwargs}')
        return f(*args, **kwargs)
    return debug_wrapper

def createLog(loglevel):
    numeric_level = getattr(logging, loglevel.upper(), None)
    if not isinstance(numeric_level, int):
        raise ValueError('Invalid log level: %s' % loglevel)
    logging.basicConfig(
        format='%(levelname)s %(asctime)s: %(message)s',
        level=numeric_level
        )
