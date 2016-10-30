class Config(object):
    DEBUG = False
    TESTING = False
    CSRF_ENABLED = True
    SECRET_KEY = 'no warnings about no-secrets'

class ProductionConfig(Config):
    pass

class TestingConfig(Config):
    DEBUG = True
    TESTING = True

class DevelopmentConfig(Config):
    DEBUG = True

