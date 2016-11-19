from flask import Flask
from flask_sqlalchemy import SQLAlchemy
from flask_migrate import Migrate, MigrateCommand
from flask_script import Manager
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
configure(app)

db = SQLAlchemy(app)

migrate = Migrate(app, db)

manager = Manager(app)
manager.add_command('db', MigrateCommand)


from articles.blueprint import articles
app.register_blueprint(articles)

