from app import db
from flask import Blueprint, jsonify, request

from articles.forms import ArticleCommentForm, ArticleForm, ValidationError
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


@articles.route('/blog/articles', methods=['POST'])
def create_article():
    form = ArticleForm.from_json(request.get_json())
    if not form.validate():
        raise ValidationError(form.errors)
    article = Article()
    article.name = form.data['name']
    db.session.add(article)
    db.session.commit()
    return jsonify(id=article.id), 201


@articles.route('/blog/articles/<int:article_id>', methods=['PUT'])
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
    comments = _fetch_all_comments_for(article_id)
    return jsonify(all_comments=comments)


@articles.route(
    '/blog/articles/<int:article_id>/comments/as_tree',
    methods=['GET']
)
def get_all_comments_as_tree(article_id):
    comments = _build_tree_of_comments(article_id)
    return jsonify(all_comments=comments)


@articles.route('/blog/articles/<int:article_id>/comments', methods=['POST'])
def create_comment(article_id):
    form = ArticleCommentForm.from_json(request.get_json())
    if not form.validate():
        raise ValidationError(form.errors)
    comment = ArticleComment()
    comment.article_id = article_id
    if 'parent_id' in form.data and isinstance(form.data['parent_id'], int):
        comment.parent_id = form.data['parent_id']
    comment.name = form.data['name']
    comment.comment = form.data['comment']
    db.session.add(comment)
    db.session.commit()
    return jsonify(id=comment.id), 201


@articles.route(
    '/blog/articles/<int:article_id>/comments/<int:comment_id>',
    methods=['PUT']
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
    if 'parent_id' in form.data and isinstance(form.data['parent_id'], int):
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


def _fetch_all_comments_for(article_id):
    resultset = (
        ArticleComment
        .query
        .filter(ArticleComment.article_id == article_id)
        .order_by(ArticleComment.parent_id, ArticleComment.id)
    )
    comments = []
    for comment in resultset:
        parent_id = 0
        if comment.parent_id is not None:
            parent_id = comment.parent_id
        comments.append(dict(
            id=comment.id,
            parent_id=parent_id,
            name=comment.name
        ))
    return comments


def _build_tree_of_comments(article_id):
    parent = {0: []}
    for comment in _fetch_all_comments_for(article_id):
        comment['comments'] = []
        parent[comment['id']] = comment['comments']
        parent[comment['parent_id']].append(comment)
    return parent[0]
