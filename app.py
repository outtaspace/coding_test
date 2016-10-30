from flask import Flask
from articles.blueprint import articles
import os


def configure(app):
    config = {
        'development': 'config.DevelopmentConfig',
        'testing': 'config.TestingConfig',
        'production': 'config.ProductionConfig',
        'default': 'config.DevelopmentConfig'
    }
    domain = os.getenv('FLASK_CONFIGURATION', 'default')
    app.config.from_object(config[domain])


app = Flask(__name__)
app.register_blueprint(articles)
configure(app)
