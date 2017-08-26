#!/usr/bin/env python

import abc
import unittest

from app import app
from blog.tests.articles import Articles
from blog.tests.article import Article
from blog.tests.article_comment import ArticleComment


class IRoutesTester(abc.ABC):
    @property
    @abc.abstractmethod
    def routing_instance(self) -> object:
        pass

    @staticmethod
    @abc.abstractmethod
    def to_absolute_url(url: str) -> str:
        pass


class TestRoutes(unittest.TestCase, IRoutesTester):
    def setUp(self) -> None:
        app.config['SERVER_NAME'] = 'tratata.org'
        self.app_context = app.app_context()
        self.app_context.push()

    def tearDown(self) -> None:
        self.app_context.pop()

    @property
    def routing_instance(self) -> object:
        pass

    @staticmethod
    def to_absolute_url(url: str) -> str:
        return 'http://' + app.config['SERVER_NAME'] + url


class TestArticlesRoutes(TestRoutes):
    @property
    def routing_instance(self) -> Articles:
        return Articles()

    def test_get_all_articles(self) -> None:
        self.assertEqual(
            self.routing_instance.get_all_articles(),
            self.to_absolute_url('/blog/articles')
        )

    def test_create_article(self) -> None:
        self.assertEqual(
            self.routing_instance.create_article(),
            self.to_absolute_url('/blog/articles')
        )


class TestArticleRoutes(TestRoutes):
    @property
    def routing_instance(self) -> Article:
        return Article(article_id=42, name='Article name')

    def test_get_article(self) -> None:
        self.assertEqual(
            self.routing_instance.get_article(),
            self.to_absolute_url('/blog/articles/42')
        )

    def test_update_article(self) -> None:
        self.assertEqual(
            self.routing_instance.update_article(),
            self.to_absolute_url('/blog/articles/42')
        )

    def test_delete_article(self) -> None:
        self.assertEqual(
            self.routing_instance.delete_article(),
            self.to_absolute_url('/blog/articles/42')
        )

    def test_create_article_comment(self) -> None:
        self.assertEqual(
            self.routing_instance.create_article_comment(),
            self.to_absolute_url('/blog/articles/42/comments')
        )

    def test_get_all_article_comments(self) -> None:
        self.assertEqual(
            self.routing_instance.get_all_article_comments(),
            self.to_absolute_url('/blog/articles/42/comments')
        )

    def test_get_all_article_comments_as_tree(self) -> None:
        self.assertEqual(
            self.routing_instance.get_all_article_comments_as_tree(),
            self.to_absolute_url('/blog/articles/42/comments/as_tree')
        )


class TestArticleCommentRoutes(TestRoutes):
    @property
    def routing_instance(self) -> ArticleComment:
        return ArticleComment(
            comment_id=2,
            article_id=42,
            parent_id=1,
            name='Comment name',
            comment='Comment'
        )

    def test_get_article_comment(self) -> None:
        self.assertEqual(
            self.routing_instance.get_article_comment(),
            self.to_absolute_url('/blog/comments/2')
        )

    def test_update_article_comment(self) -> None:
        self.assertEqual(
            self.routing_instance.update_article_comment(),
            self.to_absolute_url('/blog/comments/2')
        )

    def test_delete_article_comment(self) -> None:
        self.assertEqual(
            self.routing_instance.delete_article_comment(),
            self.to_absolute_url('/blog/comments/2')
        )


def build_suite() -> unittest.TestSuite:
    suite = unittest.TestSuite()
    suite.addTest(unittest.makeSuite(TestArticlesRoutes))
    suite.addTest(unittest.makeSuite(TestArticleRoutes))
    suite.addTest(unittest.makeSuite(TestArticleCommentRoutes))
    return suite

if __name__ == '__main__':
    unittest.TextTestRunner(verbosity=2).run(build_suite())
