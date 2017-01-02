from app import db


class Article(db.Model):
    __tablename__ = 'articles'

    id = db.Column(db.Integer, primary_key=True)  # noqa
    name = db.Column(db.String(255), nullable=False)

    comments = db.relationship(
        'ArticleComment',
        backref='articles',
        passive_deletes=True
    )

    def __repr__(self):
        return '<Article id={id}>'.format(id=self.id)


class ArticleComment(db.Model):
    __tablename__ = 'article_comments'

    id = db.Column(db.Integer, primary_key=True)  # noqa
    article_id = db.Column(
        db.Integer,
        db.ForeignKey('articles.id', ondelete='CASCADE'),
        nullable=False
    )
    parent_id = db.Column(
        db.Integer,
        nullable=False,
        server_default='0'
    )
    name = db.Column(db.String(255), nullable=False)
    comment = db.Column(db.Text, nullable=False)

    def __repr__(self):
        template = (
            '<ArticleComment'
            ' article_id={article_id},'
            ' parent_id={parent_id},'
            ' comment={comment}'
            '>'
        )
        return template.format(
            article_id=self.article_id,
            parent_id=self.parent_id,
            comment=self.comment
        )
