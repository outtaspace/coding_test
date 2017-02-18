import unittest

from app import app
from flask import json


class TestArticle:
    def __init__(self, article_id, name):
        assert isinstance(article_id, int)
        assert isinstance(name, str)

        self.article_id = article_id
        self.name = name

    @staticmethod
    def articles_url():
        return '/blog/articles'

    def article_url(self):
        return '{articles_url}/{article_id}'.format(
            articles_url=self.articles_url(),
            article_id=self.article_id
        )

    def comments_url(self):
        return '{article_url}/comments'.format(
            article_url=self.article_url()
        )

    def comments_as_tree_url(self):
        return '{comments_url}/as_tree'.format(
            comments_url=self.comments_url()
        )


class TestArticleComments:
    def __init__(self, article, comment_id, parent_id, name, comment):
        assert isinstance(article, TestArticle)
        assert isinstance(comment_id, int)
        assert isinstance(parent_id, int)
        assert isinstance(name, str)
        assert isinstance(comment, str)

        self.article = article
        self.comment_id = comment_id
        self.parent_id = parent_id
        self.name = name
        self.comment = comment

    def comment_url(self):
        return '{comments_url}/{comment_id}'.format(
            comments_url=self.article.comments_url(),
            comment_id=self.comment_id
        )


class BlogAPITest(unittest.TestCase):
    def setUp(self):
        self.app = app.test_client()

    def test_getting_all_articles(self):
        response = self.app.get(TestArticle.articles_url())

        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.content_type, 'application/json')

        data = json.loads(response.data)
        self.assertTrue(isinstance(data, list))

    def test_crud_for_articles(self):
        article = self._create_article()
        article = self._get_article(article)

        form = dict(name='Another name')
        response = self.app.put(
            article.article_url(),
            data=json.dumps(form),
            content_type='application/json'
        )
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.content_type, 'application/json')

        data = json.loads(response.data)
        self.assertEqual(data, dict())

        updated = self._get_article(article)
        self.assertEqual(updated.article_id, article.article_id)
        self.assertEqual(updated.name, form['name'])

        self._delete_article(updated)

    def test_crud_for_comments(self):
        article = self._create_article()

        comment = self._create_comment(article)
        comment = self._get_comment(comment)

        form = dict(name='Another name', comment='Another comment')
        response = self.app.put(
            comment.comment_url(),
            data=json.dumps(form),
            content_type='application/json'
        )
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.content_type, 'application/json')

        data = json.loads(response.data)
        self.assertEqual(data, dict())

        updated = self._get_comment(comment)
        self.assertEqual(updated.comment_id, comment.comment_id)
        self.assertEqual(
            updated.article.article_id,
            comment.article.article_id
        )
        self.assertEqual(updated.parent_id, comment.parent_id)
        self.assertEqual(updated.name, form['name'])
        self.assertEqual(updated.comment, form['comment'])

        self._delete_comment(comment)

        self._delete_article(article)

    def test_foreign_key(self):
        article = self._create_article()

        comment = self._create_comment(article)

        self._delete_article(article)

        response = self.app.get(comment.comment_url())
        self.assertEqual(response.status_code, 404)

    def test_getting_all_comments(self):
        article = self._create_article()

        comment_0_0 = self._create_comment(article)
        comment_0_1 = self._create_comment(article, dict(
            parent_id=comment_0_0.comment_id
        ))
        comment_0_2 = self._create_comment(article, dict(
            parent_id=comment_0_0.comment_id
        ))

        comment_1_0 = self._create_comment(article)
        comment_1_1 = self._create_comment(article, dict(
            parent_id=comment_1_0.comment_id
        ))
        comment_1_2 = self._create_comment(article, dict(
            parent_id=comment_1_0.comment_id
        ))

        comment_2_0 = self._create_comment(article)

        response = self.app.get(article.comments_url())
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.content_type, 'application/json')

        data = json.loads(response.data)
        self.assertEqual(data, [
            dict(
                id=comment_0_0.comment_id,
                parent_id=comment_0_0.parent_id,
                name=comment_0_0.name
            ),
            dict(
                id=comment_1_0.comment_id,
                parent_id=comment_1_0.parent_id,
                name=comment_1_0.name
            ),
            dict(
                id=comment_2_0.comment_id,
                parent_id=comment_2_0.parent_id,
                name=comment_2_0.name
            ),
            dict(
                id=comment_0_1.comment_id,
                parent_id=comment_0_1.parent_id,
                name=comment_0_1.name
            ),
            dict(
                id=comment_0_2.comment_id,
                parent_id=comment_0_2.parent_id,
                name=comment_0_2.name
            ),
            dict(
                id=comment_1_1.comment_id,
                parent_id=comment_1_1.parent_id,
                name=comment_1_1.name
            ),
            dict(
                id=comment_1_2.comment_id,
                parent_id=comment_1_2.parent_id,
                name=comment_1_2.name
            )
        ])

        self._delete_article(article)

    def test_getting_all_comments_as_tree(self):
        article = self._create_article()

        comment_0_0 = self._create_comment(article)
        comment_0_1 = self._create_comment(article, dict(
            parent_id=comment_0_0.comment_id
        ))
        comment_0_2 = self._create_comment(article, dict(
            parent_id=comment_0_0.comment_id
        ))

        comment_1_0 = self._create_comment(article)
        comment_1_1 = self._create_comment(article, dict(
            parent_id=comment_1_0.comment_id
        ))
        comment_1_2 = self._create_comment(article, dict(
            parent_id=comment_1_0.comment_id
        ))

        comment_2_0 = self._create_comment(article)

        response = self.app.get(article.comments_as_tree_url())
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.content_type, 'application/json')

        data = json.loads(response.data)

        self.assertEqual(data, [
            dict(
                id=comment_0_0.comment_id,
                parent_id=comment_0_0.parent_id,
                name=comment_0_0.name,
                comments=[
                    dict(
                        id=comment_0_1.comment_id,
                        parent_id=comment_0_1.parent_id,
                        name=comment_0_1.name,
                        comments=[]
                    ),
                    dict(
                        id=comment_0_2.comment_id,
                        parent_id=comment_0_2.parent_id,
                        name=comment_0_2.name,
                        comments=[]
                    )
                ]
            ),
            dict(
                id=comment_1_0.comment_id,
                parent_id=comment_1_0.parent_id,
                name=comment_1_0.name,
                comments=[
                    dict(
                        id=comment_1_1.comment_id,
                        parent_id=comment_1_1.parent_id,
                        name=comment_1_1.name,
                        comments=[]
                    ),
                    dict(
                        id=comment_1_2.comment_id,
                        parent_id=comment_1_2.parent_id,
                        name=comment_1_2.name,
                        comments=[]
                    )
                ]
            ),
            dict(
                id=comment_2_0.comment_id,
                parent_id=comment_2_0.parent_id,
                name=comment_2_0.name,
                comments=[]
            )
        ])

        self._delete_article(article)

    def _create_article(self):
        form = dict(name='Article name')

        response = self.app.post(
            TestArticle.articles_url(),
            data=json.dumps(form),
            content_type='application/json'
        )
        self.assertEqual(response.status_code, 201)
        self.assertEqual(response.content_type, 'application/json')

        data = json.loads(response.data)
        self.assertTrue(isinstance(data, dict))
        self.assertTrue('id' in data)
        self.assertTrue(isinstance(data['id'], int))

        return TestArticle(article_id=data['id'], name=form['name'])

    def _get_article(self, article):
        response = self.app.get(article.article_url())
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.content_type, 'application/json')

        data = json.loads(response.data)
        self.assertTrue(isinstance(data, dict))
        self.assertTrue('id' in data)
        self.assertTrue(isinstance(data['id'], int))
        self.assertTrue('name' in data)
        self.assertTrue(isinstance(data['name'], str))

        return TestArticle(article_id=data['id'], name=data['name'])

    def _delete_article(self, article):
        response = self.app.delete(article.article_url())
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.content_type, 'application/json')

        data = json.loads(response.data)
        self.assertEqual(data, dict())

        response = self.app.get(article.article_url())
        self.assertEqual(response.status_code, 404)
        self.assertEqual(response.content_type, 'text/html')

    def _create_comment(self, article, form=None):
        if form is None:
            form = {}
        if 'parent_id' not in form:
            form['parent_id'] = 0
        if 'name' not in form:
            form['name'] = 'Comment name'
        if 'comment' not in form:
            form['comment'] = 'Comment body'

        response = self.app.post(
            article.comments_url(),
            data=json.dumps(form),
            content_type='application/json'
        )
        self.assertEqual(response.status_code, 201)
        self.assertEqual(response.content_type, 'application/json')

        data = json.loads(response.data)
        self.assertTrue(isinstance(data, dict))
        self.assertTrue('id' in data)
        self.assertTrue(isinstance(data['id'], int))

        return TestArticleComments(
            article=article,
            comment_id=data['id'],
            parent_id=form['parent_id'],
            name=form['name'],
            comment=form['comment']
        )

    def _get_comment(self, comment):
        response = self.app.get(comment.comment_url())
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

        return TestArticleComments(
            article=comment.article,
            comment_id=data['id'],
            parent_id=data['parent_id'],
            name=data['name'],
            comment=data['comment']
        )

    def _delete_comment(self, comment):
        response = self.app.delete(comment.comment_url())
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.content_type, 'application/json')

        data = json.loads(response.data)
        self.assertEqual(data, dict())

        response = self.app.get(comment.comment_url())
        self.assertEqual(response.status_code, 404)


if __name__ == '__main__':
    unittest.main()
