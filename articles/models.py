from app import db


class Article(db.Model):
    __tablename__ = 'articles'

    id = db.Column(db.Integer, primary_key=True) 
    name = db.Column(db.String(255), nullable=False)
    comment = db.relationship('ArticleComment', cascade='all, delete-orphan')

    def __repr__(self):
        return '<Article %r>' % self.id

class ArticleComment(db.Model):
    __tablename__ = 'article_comments'

    id = db.Column(db.Integer, primary_key=True)
    article_id = db.Column(db.Integer, db.ForeignKey('articles.id'), nullable=False)
    parent_id = db.Column(db.Integer)
    comment = db.Column(db.Text, nullable=False)

    def __init__(self, article_id, parent_id, comment):
        self.id = article_id
        self.parent_id = parent_id
        self.comment

    def __repr__(self):
        return '<ArticleComment %r>' % self.article_id, self.parent_id, self.comment

