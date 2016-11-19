import unittest
from flask import json
from app import app

class BlogAPITest(unittest.TestCase):
    def setUp(self):
        self._article_id = None
        self._comment_id = None
        self.app = app.test_client()

    def _articles_url(self):
        return '/blog/articles'

    def _article_url(self):
        return self._articles_url() + '/' + self._article_id

    def _comments_url(self):
        return self._article_url() + '/comments'

    def _comment_url(self):
        return self._comments_url() + '/' + self._comment_id

    def test_getting_all_articles(self):
        response = self.app.get(self._articles_url())

        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.content_type, 'application/json')
        
        data = json.loads(response.data)
        self.assertTrue(
            type(data) is dict
            and 'articles' in data
            and type(data['articles']) is list
        )
       
    def _test_creating_article(self):
        response = self.app.put(
            self._articles_url(),
            data=json.dumps(dict(name='Article name')),
            content_type='application/json'
        )
        self.assertEqual(response.status_code, 201)
        self.assertEqual(response.content_type, 'application/json')

        data = json.loads(response.data)
        self.assertTrue(
            type(data) is dict
            and 'id' in data
            and type(data['id']) is int
        )
        self._article_id = str(data['id'])
 
    def _test_updating_article(self):
        response = self.app.post(
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
        self.assertEqual(data, dict(id=int(self._article_id), name='Another name'))

    def _test_deleting_article(self):
        response = self.app.delete(self._article_url())
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.content_type, 'application/json')

        data = json.loads(response.data)
        self.assertEqual(data, dict())

        response = self.app.get(self._article_url())
        self.assertEqual(response.status_code, 404)
        self.assertEqual(response.content_type, 'text/html')

    def _test_creating_comment(self):
        response = self.app.put(
            self._comments_url(),
            data=json.dumps(dict(
                name='Subject',
                comment='Comment',
                article_id=self._article_id
            )),
            content_type='application/json'
        )
        self.assertEqual(response.status_code, 201)
        self.assertEqual(response.content_type, 'application/json')

        data = json.loads(response.data)
        self.assertTrue(
            type(data) is dict
            and 'id' in data
            and type(data['id']) is int
        )
        self._comment_id = str(data['id'])

    def _test_updating_comment(self):
        response = self.app.post(
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
            parent_id=None,
            name='Another subject',
            comment='Another comment'
        ))

    def _test_deleting_comment(self):
        response = self.app.delete(self._comment_url())
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.content_type, 'application/json')
        
        data = json.loads(response.data)
        self.assertEqual(data, dict());

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
        self.assertTrue(
            type(data) is dict
            and 'comments' in data
            and type(data['comments']) is list
        )

        self._test_deleting_article()

    def test_crud_for_comments(self):
        self._test_creating_article()

        self._test_creating_comment()
        self._test_updating_comment()
        self._test_getting_comment()
        self._test_deleting_comment()

        self._test_deleting_article()

if __name__ == '__main__': unittest.main()

