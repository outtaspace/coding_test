from app import db
from blog import Created, handle_validation_error, OK
from blog.forms import ArticleCommentForm, ArticleForm, ValidationError
from blog.models import Article, ArticleComment
from flask import Blueprint, jsonify, request


bp = Blueprint('article', __name__)

handle_validation_error = bp.errorhandler(handle_validation_error)


@bp.route('/articles/<int:article_id>', methods=['GET'])
def get_article(article_id: int) -> OK:
    article = Article.query.filter(Article.id == article_id).first_or_404()
    db.session.add(article)
    db.session.commit()
    return jsonify(id=article.id, name=article.name)


@bp.route('/articles/<int:article_id>', methods=['PUT'])
def update_article(article_id: int) -> OK:
    form = ArticleForm.from_json(request.get_json())
    if not form.validate():
        raise ValidationError(form.errors)
    article = Article.query.filter(Article.id == article_id).first_or_404()
    article.name = form.data['name']
    db.session.add(article)
    db.session.commit()
    return jsonify()


@bp.route('/articles/<int:article_id>', methods=['DELETE'])
def delete_article(article_id: int) -> OK:
    article = Article.query.filter(Article.id == article_id).first_or_404()
    db.session.delete(article)
    db.session.commit()
    return jsonify()


@bp.route('/articles/<int:article_id>/comments', methods=['POST'])
def create_article_comment(article_id: int) -> Created:
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


@bp.route('/articles/<int:article_id>/comments', methods=['GET'])
def get_all_article_comments(article_id: int) -> OK:
    comments = _fetch_all_comments_for(article_id)
    return jsonify(comments)


@bp.route('/articles/<int:article_id>/comments/as_tree', methods=['GET'])
def get_all_article_comments_as_tree(article_id: int) -> OK:
    comments = _build_tree_of_comments(article_id)
    return jsonify(comments)


def _fetch_all_comments_for(article_id: int) -> list:
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


def _build_tree_of_comments(article_id: int) -> list:
    parent = {0: []}
    for comment in _fetch_all_comments_for(article_id):
        comment['comments'] = []
        parent[comment['id']] = comment['comments']
        parent[comment['parent_id']].append(comment)
    return parent[0]
