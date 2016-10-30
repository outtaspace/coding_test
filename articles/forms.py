import wtforms
from wtforms import validators


class ArticleForm(wtforms.Form):
    parent_id = wtforms.IntegerField('parent_id', validators=[validators.DataRequired()])
    comment = wtforms.TextAreaField('comment', validators=[validators.DataRequired()])


class ValidationError(Exception):
    status_code = 422

    def __init__(self, errors):
        Exception.__init__(self)
        self.errors = errors

    def to_dict(self):
        return dict(self.errors or ())
