from flask import url_for


class Article:
    def __init__(self, article_id: int, name: str) -> None:
        assert isinstance(article_id, int)
        assert isinstance(name, str)

        self.id = article_id
        self.name = name

    def get_article(self) -> str:
        return url_for('article.get_article', article_id=self.id)

    def update_article(self) -> str:
        return url_for('article.update_article', article_id=self.id)

    def delete_article(self) -> str:
        return url_for('article.delete_article', article_id=self.id)

    def create_article_comment(self) -> str:
        return url_for('article.create_article_comment', article_id=self.id)

    def get_all_article_comments(self) -> str:
        return url_for('article.get_all_article_comments', article_id=self.id)

    def get_all_article_comments_as_tree(self) -> str:
        return url_for('article.get_all_article_comments_as_tree', article_id=self.id)
