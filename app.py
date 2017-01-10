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


def register_extensions(app):
    db.init_app(app)


def register_blueprints(app):
    from articles.blueprint import articles
    app.register_blueprint(articles)


db = SQLAlchemy()

app = Flask(__name__)
configure(app)
register_extensions(app)
register_blueprints(app)
