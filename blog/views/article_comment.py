from app import db
from flask import Blueprint, jsonify, request

from blog import handle_validation_error, OK
from blog.forms import ArticleCommentForm, ValidationError
from blog.models import ArticleComment

bp = Blueprint('article_comment', __name__)

handle_validation_error = bp.errorhandler(handle_validation_error)


@bp.route('/comments/<int:comment_id>', methods=['GET'])
def get_comment(comment_id: int) -> OK:
    comment = (
        ArticleComment
        .query
        .filter(ArticleComment.id == comment_id)
        .first_or_404()
    )
    return jsonify(
        id=comment.id,
        article_id=comment.article_id,
        parent_id=comment.parent_id,
        name=comment.name,
        comment=comment.comment
    )


@bp.route('/comments/<int:comment_id>', methods=['PUT'])
def update_comment(comment_id: int) -> OK:
    form = ArticleCommentForm.from_json(request.get_json())
    if not form.validate():
        raise ValidationError(form.errors)
    comment = (
        ArticleComment
        .query
        .filter(ArticleComment.id == comment_id)
        .first_or_404()
    )
    comment.name = form.data['name']
    comment.comment = form.data['comment']
    db.session.add(comment)
    db.session.commit()
    return jsonify()


@bp.route('/comments/<int:comment_id>', methods=['DELETE'])
def delete_comment(comment_id: int) -> OK:
    comment = (
        ArticleComment
        .query
        .filter(ArticleComment.id == comment_id)
        .first_or_404()
    )
    db.session.delete(comment)
    db.session.commit()
    return jsonify()
