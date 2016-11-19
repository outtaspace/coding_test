from flask import Blueprint, request, jsonify
from sqlalchemy.orm import load_only
from app import db
from articles.forms import ArticleForm, ValidationError
from articles.models import Article, ArticleComment


articles = Blueprint('articles', __name__)


@articles.errorhandler(ValidationError)
def handle_validation_error(error):
    response = jsonify(error.to_dict())
    response.status_code = error.status_code
    return response

@articles.route('/blog/articles', methods=['GET'])
def get_all_articles():
    articles = []
    for row in Article.query.all():
        articles.append(dict(id=row.id, name=row.name))
    return jsonify(articles=articles)

@articles.route('/blog/articles', methods=['PUT'])
def create_article():
    form = ArticleForm.from_json(request.get_json())
    if not form.validate():
        raise ValidationError(form.errors)
    article = Article()
    article.name = form.data['name']
    db.session.add(article)
    db.session.commit()
    return jsonify(id=article.id), 201

@articles.route('/blog/articles/<int:article_id>', methods=['POST'])
def update_article(article_id):
    form = ArticleForm.from_json(request.get_json())
    if not form.validate():
        raise ValidationError(form.errors)
    article = Article.query.filter(Article.id == article_id).first_or_404()
    article.name = form.data['name']
    db.session.add(article)
    db.session.commit()
    return jsonify()

@articles.route('/blog/articles/<int:article_id>', methods=['GET'])
def get_article(article_id):
    article = Article.query.filter(Article.id == article_id).first_or_404()
    db.session.add(article)
    db.session.commit()
    return jsonify(dict(id=article.id, name=article.name))

@articles.route('/blog/articles/<int:article_id>', methods=['DELETE'])
def delete_article(article_id):
    article = Article.query.filter(Article.id == article_id).first_or_404()
    db.session.delete(article)
    db.session.commit()
    return jsonify()

