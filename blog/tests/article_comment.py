from flask import url_for


class ArticleComment:
    def __init__(self, comment_id: int, article_id: int, parent_id: int, name: str, comment: str) -> None:
        assert isinstance(comment_id, int)
        assert isinstance(article_id, int)
        assert isinstance(parent_id, int)
        assert isinstance(name, str)
        assert isinstance(comment, str)

        self.id = comment_id
        self.article_id = article_id
        self.parent_id = parent_id
        self.name = name
        self.comment = comment

    def get_article_comment(self) -> str:
        return url_for('article_comment.get_comment', comment_id=self.id)

    def update_article_comment(self) -> str:
        return url_for('article_comment.update_comment', comment_id=self.id)

    def delete_article_comment(self) -> str:
        return url_for('article_comment.delete_comment', comment_id=self.id)
