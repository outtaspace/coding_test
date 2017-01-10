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


def register_blueprints(app):
    from articles.blueprint import articles
    app.register_blueprint(articles)


app = Flask(__name__)
configure(app)

db = SQLAlchemy(app)

register_blueprints(app)
