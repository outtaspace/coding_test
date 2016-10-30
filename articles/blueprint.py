from flask import Blueprint, request, jsonify

articles = Blueprint('articles', __name__)

@articles.route('/blog/articles', methods=['GET'])
def get_all_articles():
    return jsonify(articles=[])

@articles.route('/blog/articles', methods=['POST'])
def create_article():
    return jsonify(article_id=42)

@articles.route('/blog/articles/<int:article_id>', methods=['GET'])
def get_article(article_id):
    return jsonify(article={})

@articles.route('/blog/articles/<int:article_id>', methods=['DELETE'])
def delete_article(article_id):
    return jsonify()

