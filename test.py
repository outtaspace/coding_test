#!/usr/bin/env python

import unittest

import tests.routes_test
import tests.views_test

if __name__ == '__main__':
    all_suites = unittest.TestSuite([
        tests.routes_test.build_suite(),
        tests.views_test.build_suite()
    ])
    unittest.TextTestRunner(verbosity=2).run(all_suites)
