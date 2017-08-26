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
    from blog.views.articles import bp as articles_bp
    from blog.views.article import bp as article_bp
    from blog.views.article_comment import bp as article_comment_bp

    url_prefix = '/blog'
    app.register_blueprint(articles_bp, url_prefix=url_prefix)
    app.register_blueprint(article_bp, url_prefix=url_prefix)
    app.register_blueprint(article_comment_bp, url_prefix=url_prefix)


db = SQLAlchemy()

app = Flask(__name__)
configure(app)
register_extensions(app)
register_blueprints(app)
