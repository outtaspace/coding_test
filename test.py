import unittest
from flask import json
from app import app

class BlogAPITest(unittest.TestCase):
    def setUp(self):
        self.app = app.test_client()

    def test_getting_all_articles(self):
        response = self.app.get('/blog/articles')

        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.content_type, 'application/json')
        
        data = json.loads(response.data)
        self.assertTrue(type(data) is dict)
        self.assertTrue('articles' in data)
        self.assertTrue(type(data['articles']) is list)
       
    def test_creating_article(self):
        data = {
            'parent_id': 0,
            'comment': ''
        }
        response = self.app.post('/blog/articles', data=json.dumps(data))

        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.content_type, 'application/json')
        
        data = json.loads(response.data)
        self.assertTrue(type(data) is dict)
        self.assertTrue('article_id' in data)
        self.assertEqual(int(data['article_id']), 42)
 
    def test_getting_article(self):
        response = self.app.get('/blog/articles/42')

        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.content_type, 'application/json')

        data = json.loads(response.data)
        self.assertTrue(type(data) is dict)
        self.assertTrue('article' in data)
        self.assertTrue(type(data['article']) is dict)

    def test_deleting_article(self):
        response = self.app.get('/blog/articles/42')

        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.content_type, 'application/json')

        data = json.loads(response.data)
        self.assertTrue(type(data) is dict)

       
if __name__ == '__main__': unittest.main()
