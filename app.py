import os

from flask import Flask

from flask_sqlalchemy import SQLAlchemy


def configure(app):
    config = dict(
        development='config.DevelopmentConfig',
        testing='config.TestingConfig',
        production='config.ProductionConfig',
        default='config.DevelopmentConfig'
    )
    domain = os.getenv('FLASK_CONFIGURATION', 'default')
    app.config.from_object(config[domain])


app = Flask(__name__)
configure(app)

db = SQLAlchemy(app)

from articles.blueprint import articles # noqa
app.register_blueprint(articles)
