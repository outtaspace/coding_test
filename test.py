import unittest

from app import app
from flask import json


class BlogAPITest(unittest.TestCase):

    def setUp(self):
        self._article_id = None
        self._comment_id = None
        self.app = app.test_client()

    def _articles_url(self):
        return '/blog/articles'

    def _article_url(self):
        return '{articles_url}/{article_id}'.format(
            articles_url=self._articles_url(),
            article_id=self._article_id
        )

    def _comments_url(self):
        return '{article_url}/comments'.format(
            article_url=self._article_url()
        )

    def _comments_as_tree_url(self):
        return '{article_url}/comments/as_tree'.format(
            article_url=self._article_url()
        )

    def _comment_url(self):
        return '{comments_url}/{comment_id}'.format(
            comments_url=self._comments_url(),
            comment_id=self._comment_id
        )

    def test_getting_all_articles(self):
        response = self.app.get(self._articles_url())

        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.content_type, 'application/json')

        data = json.loads(response.data)
        self.assertTrue(isinstance(data, dict))
        self.assertTrue('articles' in data)
        self.assertTrue(isinstance(data['articles'], list))

    def _test_creating_article(self):
        response = self.app.post(
            self._articles_url(),
            data=json.dumps(dict(name='Article name')),
            content_type='application/json'
        )
        self.assertEqual(response.status_code, 201)
        self.assertEqual(response.content_type, 'application/json')

        data = json.loads(response.data)
        self.assertTrue(isinstance(data, dict))
        self.assertTrue('id' in data)
        self.assertTrue(isinstance(data['id'], int))
        self._article_id = str(data['id'])

    def _test_updating_article(self):
        response = self.app.put(
            self._article_url(),
            data=json.dumps(dict(name='Another name')),
            content_type='application/json'
        )
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.content_type, 'application/json')

        data = json.loads(response.data)
        self.assertEqual(data, dict())

    def _test_getting_article(self):
        response = self.app.get(self._article_url())
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.content_type, 'application/json')

        data = json.loads(response.data)
        self.assertEqual(data, dict(
            id=int(self._article_id),
            name='Another name'
        ))

    def _test_deleting_article(self):
        response = self.app.delete(self._article_url())
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.content_type, 'application/json')

        data = json.loads(response.data)
        self.assertEqual(data, dict())

        response = self.app.get(self._article_url())
        self.assertEqual(response.status_code, 404)
        self.assertEqual(response.content_type, 'text/html')

    def _test_creating_comment(self, parent_id=None):
        response = self.app.post(
            self._comments_url(),
            data=json.dumps(dict(
                name='Subject',
                comment='Comment',
                article_id=self._article_id,
                parent_id=parent_id
            )),
            content_type='application/json'
        )
        self.assertEqual(response.status_code, 201)
        self.assertEqual(response.content_type, 'application/json')

        data = json.loads(response.data)
        self.assertTrue(isinstance(data, dict))
        self.assertTrue('id' in data)
        self.assertTrue(isinstance(data['id'], int))
        self._comment_id = str(data['id'])

    def _test_updating_comment(self):
        response = self.app.put(
            self._comment_url(),
            data=json.dumps(dict(
                name='Another subject',
                comment='Another comment',
                article_id=self._article_id
            )),
            content_type='application/json'
        )
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.content_type, 'application/json')

        data = json.loads(response.data)
        self.assertEqual(data, dict())

    def _test_getting_comment(self):
        response = self.app.get(self._comment_url())
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.content_type, 'application/json')

        data = json.loads(response.data)
        self.assertEqual(data, dict(
            id=int(self._comment_id),
            article_id=int(self._article_id),
            parent_id=0,
            name='Another subject',
            comment='Another comment'
        ))

    def _test_deleting_comment(self):
        response = self.app.delete(self._comment_url())
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.content_type, 'application/json')

        data = json.loads(response.data)
        self.assertEqual(data, dict())

    def test_crud_for_articles(self):
        self._test_creating_article()
        self._test_updating_article()
        self._test_getting_article()
        self._test_deleting_article()

    def test_getting_all_comments(self):
        self._test_creating_article()

        response = self.app.get(self._comments_url())

        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.content_type, 'application/json')

        data = json.loads(response.data)
        self.assertTrue(isinstance(data, dict))
        self.assertTrue('all_comments' in data)
        self.assertTrue(isinstance(data['all_comments'], list))

        self._test_deleting_article()

    def test_crud_for_comments(self):
        self._test_creating_article()

        self._test_creating_comment()
        self._test_updating_comment()
        self._test_getting_comment()
        self._test_deleting_comment()

        self._test_deleting_article()

    def test_getting_all_comments_as_tree(self):
        self._test_creating_article()

        response = self.app.get(self._comments_as_tree_url())
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.content_type, 'application/json')

        data = json.loads(response.data)
        self.assertTrue(isinstance(data, dict))
        self.assertTrue('all_comments' in data)
        self.assertTrue(isinstance(data['all_comments'], list))
        self.assertTrue(len(data['all_comments']) == 0)

        self._test_creating_comment()

        response = self.app.get(self._comments_as_tree_url())
        data = json.loads(response.data)
        self.assertTrue(isinstance(data, dict))
        self.assertTrue('all_comments' in data)
        self.assertTrue(isinstance(data['all_comments'], list))
        self.assertTrue(len(data['all_comments']) == 1)
        self.assertTrue(isinstance(data['all_comments'][0], dict))
        parent = data['all_comments'][0]
        parent_id = parent['id']
        self.assertTrue('comments' in parent)
        self.assertTrue(isinstance(parent['comments'], list))
        self.assertTrue(len(parent['comments']) == 0)

        self._test_creating_comment(parent_id)

        response = self.app.get(self._comments_as_tree_url())
        data = json.loads(response.data)
        parent = data['all_comments'][0]
        self.assertTrue(parent['id'] == parent_id)
        self.assertTrue(len(parent['comments']) == 1)
        self.assertTrue(parent['comments'][0]['id'] == int(self._comment_id))
        self.assertTrue(parent['comments'][0]['parent_id'] == parent_id)

        self._test_deleting_article()


if __name__ == '__main__':
    unittest.main()
