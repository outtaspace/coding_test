class Config(object):
    DEBUG = False
    TESTING = False
    CSRF_ENABLED = True
    SECRET_KEY = 'no warnings about no-secrets'
    SQLALCHEMY_DATABASE_URI = 'mysql+mysqlconnector://coding_test:coding_test@localhost/coding_test'
    SQLALCHEMY_TRACK_MODIFICATIONS = True


class ProductionConfig(Config):
    pass


class TestingConfig(Config):
    DEBUG = True
    TESTING = True


class DevelopmentConfig(Config):
    DEBUG = True
