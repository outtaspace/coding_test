#!/usr/bin/env python

import unittest
from app import app
from flask import json

from blog.tests.articles import Articles
from blog.tests.article import Article
from blog.tests.article_comment import ArticleComment


class TestViews(unittest.TestCase):
    def setUp(self) -> None:
        app.config['SERVER_NAME'] = 'tratata.org'
        self.app_context = app.app_context()
        self.app_context.push()
        self.client = app.test_client()

    def tearDown(self) -> None:
        self.app_context.pop()

    def test_getting_all_articles(self) -> None:
        response = self.client.get(Articles().get_all_articles())
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.content_type, 'application/json')

        data = json.loads(response.data)
        self.assertTrue(isinstance(data, list))

    def test_crud_for_articles(self) -> None:
        article = self.create_article()
        article = self.get_article(article)

        form = dict(name='Another name')
        response = self.client.put(
            article.update_article(),
            data=json.dumps(form),
            content_type='application/json'
        )
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.content_type, 'application/json')
        self.assertEqual(json.loads(response.data), dict())

        updated = self.get_article(article)
        self.assertEqual(updated.id, article.id)
        self.assertEqual(updated.name, form['name'])

        self.delete_article(updated)

    def test_crud_for_comments(self):
        article = self.create_article()

        comment = self.create_comment(article)
        comment = self.get_comment(comment)

        form = dict(name='Another name', comment='Another comment')
        response = self.client.put(
            comment.update_article_comment(),
            data=json.dumps(form),
            content_type='application/json'
        )
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.content_type, 'application/json')
        self.assertEqual(json.loads(response.data), dict())

        updated = self.get_comment(comment)
        self.assertEqual(updated.id, comment.id)
        self.assertEqual(updated.article_id, comment.article_id)
        self.assertEqual(updated.parent_id, comment.parent_id)
        self.assertEqual(updated.name, form['name'])
        self.assertEqual(updated.comment, form['comment'])

        self.delete_comment(comment)
        self.delete_article(article)

    def test_foreign_key(self):
        article = self.create_article()
        comment = self.create_comment(article)
        self.delete_article(article)
        self.check_comment_is_deleted(comment)

    def test_getting_all_comments(self):
        article = self.create_article()

        comment_0_0 = self.create_comment(article)
        comment_0_1 = self.create_comment(article, dict(
            parent_id=comment_0_0.id
        ))
        comment_0_2 = self.create_comment(article, dict(
            parent_id=comment_0_0.id
        ))
        comment_1_0 = self.create_comment(article)
        comment_1_1 = self.create_comment(article, dict(
            parent_id=comment_1_0.id
        ))
        comment_1_2 = self.create_comment(article, dict(
            parent_id=comment_1_0.id
        ))
        comment_2_0 = self.create_comment(article)

        response = self.client.get(article.get_all_article_comments())
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.content_type, 'application/json')

        data = json.loads(response.data)
        self.assertEqual(data, [
            dict(
                id=comment_0_0.id,
                parent_id=comment_0_0.parent_id,
                name=comment_0_0.name
            ),
            dict(
                id=comment_1_0.id,
                parent_id=comment_1_0.parent_id,
                name=comment_1_0.name
            ),
            dict(
                id=comment_2_0.id,
                parent_id=comment_2_0.parent_id,
                name=comment_2_0.name
            ),
            dict(
                id=comment_0_1.id,
                parent_id=comment_0_1.parent_id,
                name=comment_0_1.name
            ),
            dict(
                id=comment_0_2.id,
                parent_id=comment_0_2.parent_id,
                name=comment_0_2.name
            ),
            dict(
                id=comment_1_1.id,
                parent_id=comment_1_1.parent_id,
                name=comment_1_1.name
            ),
            dict(
                id=comment_1_2.id,
                parent_id=comment_1_2.parent_id,
                name=comment_1_2.name
            )
        ])

        self.delete_article(article)

    def test_getting_all_comments_as_tree(self):
        article = self.create_article()

        comment_0_0 = self.create_comment(article)
        comment_0_1 = self.create_comment(article, dict(
            parent_id=comment_0_0.id
        ))
        comment_0_2 = self.create_comment(article, dict(
            parent_id=comment_0_0.id
        ))
        comment_1_0 = self.create_comment(article)
        comment_1_1 = self.create_comment(article, dict(
            parent_id=comment_1_0.id
        ))
        comment_1_2 = self.create_comment(article, dict(
            parent_id=comment_1_0.id
        ))
        comment_2_0 = self.create_comment(article)

        response = self.client.get(article.get_all_article_comments_as_tree())
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.content_type, 'application/json')

        data = json.loads(response.data)
        self.assertEqual(data, [
            dict(
                id=comment_0_0.id,
                parent_id=comment_0_0.parent_id,
                name=comment_0_0.name,
                comments=[
                    dict(
                        id=comment_0_1.id,
                        parent_id=comment_0_1.parent_id,
                        name=comment_0_1.name,
                        comments=[]
                    ),
                    dict(
                        id=comment_0_2.id,
                        parent_id=comment_0_2.parent_id,
                        name=comment_0_2.name,
                        comments=[]
                    )
                ]
            ),
            dict(
                id=comment_1_0.id,
                parent_id=comment_1_0.parent_id,
                name=comment_1_0.name,
                comments=[
                    dict(
                        id=comment_1_1.id,
                        parent_id=comment_1_1.parent_id,
                        name=comment_1_1.name,
                        comments=[]
                    ),
                    dict(
                        id=comment_1_2.id,
                        parent_id=comment_1_2.parent_id,
                        name=comment_1_2.name,
                        comments=[]
                    )
                ]
            ),
            dict(
                id=comment_2_0.id,
                parent_id=comment_2_0.parent_id,
                name=comment_2_0.name,
                comments=[]
            )
        ])

        self.delete_article(article)

    def create_article(self) -> Article:
        form = dict(name='Article name')

        response = self.client.post(
            Articles.create_article(),
            data=json.dumps(form),
            content_type='application/json'
        )
        self.assertEqual(response.status_code, 201)
        self.assertEqual(response.content_type, 'application/json')

        data = json.loads(response.data)
        self.assertTrue(isinstance(data, dict))
        self.assertTrue('id' in data)
        self.assertTrue(isinstance(data['id'], int))

        return Article(article_id=data['id'], name=form['name'])

    def get_article(self, article: Article) -> Article:
        response = self.client.get(article.get_article())
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.content_type, 'application/json')

        data = json.loads(response.data)
        self.assertTrue(isinstance(data, dict))
        self.assertTrue('id' in data)
        self.assertTrue(isinstance(data['id'], int))
        self.assertTrue('name' in data)
        self.assertTrue(isinstance(data['name'], str))

        return Article(article_id=data['id'], name=data['name'])

    def delete_article(self, article: Article) -> None:
        response = self.client.delete(article.delete_article())
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.content_type, 'application/json')

        data = json.loads(response.data)
        self.assertEqual(data, dict())

        self.check_article_is_deleted(article)

    def check_article_is_deleted(self, article: Article):
        response = self.client.get(article.get_article())
        self.assertEqual(response.status_code, 404)
        self.assertEqual(response.content_type, 'text/html')

    def create_comment(self, article: Article, form=None) -> ArticleComment:
        if form is None:
            form = {}
        if 'parent_id' not in form:
            form['parent_id'] = 0
        if 'name' not in form:
            form['name'] = 'Comment name'
        if 'comment' not in form:
            form['comment'] = 'Comment body'

        response = self.client.post(
            article.create_article_comment(),
            data=json.dumps(form),
            content_type='application/json'
        )
        self.assertEqual(response.status_code, 201)
        self.assertEqual(response.content_type, 'application/json')

        data = json.loads(response.data)
        self.assertTrue(isinstance(data, dict))
        self.assertTrue('id' in data)
        self.assertTrue(isinstance(data['id'], int))

        return ArticleComment(
            comment_id=data['id'],
            article_id=article.id,
            parent_id=form['parent_id'],
            name=form['name'],
            comment=form['comment']
        )

    def get_comment(self, comment: ArticleComment) -> ArticleComment:
        response = self.client.get(comment.get_article_comment())
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.content_type, 'application/json')

        data = json.loads(response.data)
        self.assertTrue(isinstance(data, dict))
        self.assertTrue('id' in data)
        self.assertTrue(isinstance(data['id'], int))
        self.assertTrue('article_id' in data)
        self.assertTrue(isinstance(data['article_id'], int))
        self.assertTrue('parent_id' in data)
        self.assertTrue(isinstance(data['parent_id'], int))
        self.assertTrue('name' in data)
        self.assertTrue(isinstance(data['name'], str))
        self.assertTrue('comment' in data)
        self.assertTrue(isinstance(data['comment'], str))

        return ArticleComment(
            comment_id=data['id'],
            article_id=data['article_id'],
            parent_id=data['parent_id'],
            name=data['name'],
            comment=data['comment']
        )

    def delete_comment(self, comment: ArticleComment) -> None:
        response = self.client.delete(comment.delete_article_comment())
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.content_type, 'application/json')

        data = json.loads(response.data)
        self.assertEqual(data, dict())

        self.check_comment_is_deleted(comment)

    def check_comment_is_deleted(self, comment: ArticleComment) -> None:
        response = self.client.get(comment.get_article_comment())
        self.assertEqual(response.status_code, 404)
        self.assertEqual(response.content_type, 'text/html')


def build_suite() -> unittest.TestSuite:
    suite = unittest.TestSuite()
    suite.addTest(unittest.makeSuite(TestViews))
    return suite

if __name__ == '__main__':
    unittest.TextTestRunner(verbosity=2).run(build_suite())
