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
        response = self.app.post(
            '/blog/articles',
            data=dict(parent_id=42, comment='tratata'),
            content_type='application/x-www-form-urlencoded'
        )
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.content_type, 'application/json')
        
        data = json.loads(response.data)
        self.assertTrue(type(data) is dict)
        self.assertTrue('article_id' in data)
        self.assertEqual(int(data['article_id']), 42)
 

    def test_creating_article_validation(self):
        # parent_id is not exists
        response = self.app.post(
            '/blog/articles',
            data=dict(comment='tratata'),
            content_type='application/x-www-form-urlencoded'
        )
        self.assertEqual(response.status_code, 422)
        self.assertEqual(response.content_type, 'application/json')
        data = json.loads(response.data)
        self.assertTrue(
            type(data) is dict
            and 'parent_id' in data
            and type(data['parent_id']) is list
            and len(data['parent_id']) == 1
            and data['parent_id'][0] == 'This field is required.'
        )

        # parent_id is empty string
        response = self.app.post(
            '/blog/articles',
            data=dict(parent_id='', comment='tratata'),
            content_type='application/x-www-form-urlencoded'
        )
        self.assertEqual(response.status_code, 422)
        self.assertEqual(response.content_type, 'application/json')
        data = json.loads(response.data)
        self.assertTrue(
            type(data) is dict
            and 'parent_id' in data
            and type(data['parent_id']) is list
            and len(data['parent_id']) == 1
            and data['parent_id'][0] == 'This field is required.'
        )

        # parent_id is not integer
        response = self.app.post(
            '/blog/articles',
            data=dict(parent_id='tratata', comment='tratata'),
            content_type='application/x-www-form-urlencoded'
        )
        self.assertEqual(response.status_code, 422)
        self.assertEqual(response.content_type, 'application/json')
        data = json.loads(response.data)
        self.assertTrue(
            type(data) is dict
            and 'parent_id' in data
            and type(data['parent_id']) is list
            and len(data['parent_id']) == 1
            and data['parent_id'][0] == 'This field is required.'
        )

        # comment is not exists
        response = self.app.post(
            '/blog/articles',
            data=dict(parent_id=0),
            content_type='application/x-www-form-urlencoded'
        )
        self.assertEqual(response.status_code, 422)
        self.assertEqual(response.content_type, 'application/json')
        data = json.loads(response.data)
        self.assertTrue(
            type(data) is dict
            and 'parent_id' in data
            and type(data['parent_id']) is list
            and len(data['parent_id']) == 1
            and data['parent_id'][0] == 'This field is required.'
        )


        # comment is empty string
        response = self.app.post(
            '/blog/articles',
            data=dict(parent_id=0, comment=''),
            content_type='application/x-www-form-urlencoded'
        )
        self.assertEqual(response.status_code, 422)
        self.assertEqual(response.content_type, 'application/json')
        data = json.loads(response.data)
        self.assertTrue(
            type(data) is dict
            and 'parent_id' in data
            and type(data['parent_id']) is list
            and len(data['parent_id']) == 1
            and data['parent_id'][0] == 'This field is required.'
        )

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
