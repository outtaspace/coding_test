from reprlib import repr

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

    def __repr__(self) -> str:
        template = 'Article(id={id}, name="{name}")'
        return template.format(id=self.id, name=repr(self.name))


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

    def __repr__(self) -> str:
        template = (
            'ArticleComment(id={id},'
            ' article_id={article_id},'
            ' parent_id={parent_id},'
            ' name="{name}",'
            ' comment="{comment}"'
            ')'
        )
        return template.format(
            id=self.id,
            article_id=self.article_id,
            parent_id=self.parent_id,
            name=repr(self.name),
            comment=repr(self.comment)
        )
