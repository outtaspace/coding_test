from flask import url_for


class Articles:
    @staticmethod
    def get_all_articles() -> str:
        return url_for('articles.get_all_articles')

    @staticmethod
    def create_article() -> str:
        return url_for('articles.create_article')
