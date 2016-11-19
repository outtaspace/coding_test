import unittest
from flask import json
from app import app

class BlogAPITest(unittest.TestCase):
    def setUp(self):
        self._article_id = None
        self.app = app.test_client()

    def _articles_url(self):
        return '/blog/articles'

    def _article_url(self):
        return self._articles_url() + '/' + self._article_id

    def test_getting_all_articles(self):
        response = self.app.get(self._articles_url())

        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.content_type, 'application/json')
        
        data = json.loads(response.data)
        self.assertTrue(type(data) is dict)
       
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

    def test_crud(self):
        self._test_creating_article()
        self._test_updating_article()
        self._test_getting_article()
        self._test_deleting_article()

       
if __name__ == '__main__': unittest.main()

