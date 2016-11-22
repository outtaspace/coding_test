from flask import Blueprint, request, jsonify
from sqlalchemy.orm import load_only
from app import db
from articles.forms import ArticleForm, ArticleCommentForm, ValidationError
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
    return jsonify(id=article.id, name=article.name)


@articles.route('/blog/articles/<int:article_id>', methods=['DELETE'])
def delete_article(article_id):
    article = Article.query.filter(Article.id == article_id).first_or_404()
    db.session.delete(article)
    db.session.commit()
    return jsonify()


@articles.route('/blog/articles/<int:article_id>/comments', methods=['GET'])
def get_all_comments(article_id):
    comments = []
    for comment in ArticleComment.query.filter(ArticleComment.article_id == article_id):
        comments.append(dict(
            id=comment.id,
            parent_id=comment.parent_id,
            name=comment.name
        ))
    return jsonify(comments=comments)


@articles.route('/blog/articles/<int:article_id>/comments', methods=['PUT'])
def create_comment(article_id):
    form = ArticleCommentForm.from_json(request.get_json())
    if not form.validate():
        raise ValidationError(form.errors)
    comment = ArticleComment()
    comment.article_id = article_id
    if 'parent_id' in form.data and type(form.data['parent_id']) is int:
        comment.parent_id = form.data['parent_id']
    comment.name = form.data['name']
    comment.comment = form.data['comment']
    db.session.add(comment)
    db.session.commit()
    return jsonify(id=comment.id), 201


@articles.route(
    '/blog/articles/<int:article_id>/comments/<int:comment_id>',
    methods=['POST']
)
def update_comment(article_id, comment_id):
    form = ArticleCommentForm.from_json(request.get_json())
    if not form.validate():
        raise ValidationError(form.errors)
    comment = (
        ArticleComment
        .query
        .filter(ArticleComment.id == comment_id)
        .filter(ArticleComment.article_id == article_id)
        .first_or_404()
    )
    comment.article_id = article_id
    if 'parent_id' in form.data and type(form.data['parent_id']) is int:
        comment.parent_id = form.data['parent_id']
    comment.name = form.data['name']
    comment.comment = form.data['comment']
    db.session.add(comment)
    db.session.commit()
    return jsonify()


@articles.route(
    '/blog/articles/<int:article_id>/comments/<int:comment_id>',
    methods=['GET']
)
def get_comment(article_id, comment_id):
    comment = (
        ArticleComment
        .query
        .filter(ArticleComment.id == comment_id)
        .filter(ArticleComment.article_id == article_id)
        .order_by(ArticleComment.parent_id, ArticleComment.id)
        .first_or_404()
    )
    return jsonify(
        id=comment.id,
        article_id=comment.article_id,
        parent_id=comment.parent_id,
        name=comment.name,
        comment=comment.comment
    )


@articles.route(
    '/blog/articles/<int:article_id>/comments/<int:comment_id>',
    methods=['DELETE']
)
def delete_comment(article_id, comment_id):
    comment = (
        ArticleComment
        .query
        .filter(ArticleComment.id == comment_id)
        .filter(ArticleComment.article_id == article_id)
        .first_or_404()
    )
    db.session.delete(comment)
    db.session.commit()
    return jsonify()
