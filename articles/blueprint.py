from flask import Blueprint, request, jsonify
from articles.forms import ArticleForm, ValidationError


articles = Blueprint('articles', __name__)


@articles.errorhandler(ValidationError)
def handle_validation_error(error):
    response = jsonify(error.to_dict())
    response.status_code = error.status_code
    return response

@articles.route('/blog/articles', methods=['GET'])
def get_all_articles():
    return jsonify(articles=[])

@articles.route('/blog/articles', methods=['POST'])
def create_article():
    form = ArticleForm(request.form)
    if not form.validate():
        raise ValidationError(form.errors)

    return jsonify(article_id=42)

@articles.route('/blog/articles/<int:article_id>', methods=['GET'])
def get_article(article_id):
    return jsonify(article={})

@articles.route('/blog/articles/<int:article_id>', methods=['DELETE'])
def delete_article(article_id):
    return jsonify()
