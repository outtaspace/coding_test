import wtforms
import wtforms_json
from wtforms import validators


wtforms_json.init()


class ArticleForm(wtforms.Form):
    id = wtforms.IntegerField('id', validators=[validators.Optional()])
    name = wtforms.StringField('name', validators=[validators.DataRequired()])


class ArticleCommentForm(wtforms.Form):
    id = wtforms.IntegerField('id', validators=[validators.Optional()])
    parent_id = wtforms.IntegerField('parent_id', validators=[
        validators.Optional()
    ])
    name = wtforms.StringField('name', validators=[validators.DataRequired()])
    comment = wtforms.TextAreaField('comment', validators=[
        validators.DataRequired()
    ])


class ValidationError(Exception):
    status_code = 422

    def __init__(self, errors):
        Exception.__init__(self)
        self.errors = errors

    def to_dict(self):
        return dict(self.errors or ())
