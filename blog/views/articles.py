from app import db
from flask import Blueprint, jsonify, request

from blog import handle_validation_error, OK, Created
from blog.forms import ArticleForm, ValidationError
from blog.models import Article

bp = Blueprint('articles', __name__)

handle_validation_error = bp.errorhandler(handle_validation_error)


@bp.route('/articles', methods=['GET'])
def get_all_articles() -> OK:
    articles = []
    for row in Article.query.all():
        articles.append(dict(id=row.id, name=row.name))
    return jsonify(articles)


@bp.route('/articles', methods=['POST'])
def create_article() -> Created:
    form = ArticleForm.from_json(request.get_json())
    if not form.validate():
        raise ValidationError(form.errors)
    article = Article()
    article.name = form.data['name']
    db.session.add(article)
    db.session.commit()
    return jsonify(id=article.id), 201
