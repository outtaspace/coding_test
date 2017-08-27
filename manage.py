import unittest

from app import app, db
from flask_migrate import Migrate, MigrateCommand
from flask_script import Command, Manager, Option
import tests.routes_test
import tests.views_test


class RunTests(Command):
    """Run the tests."""
    option_list = (
        Option('--verbosity', type=int, default=2),
    )

    @staticmethod
    def run(verbosity: int) -> None:
        all_suites = unittest.TestSuite([
            tests.routes_test.build_suite(),
            tests.views_test.build_suite()
        ])
        unittest.TextTestRunner(verbosity=verbosity).run(all_suites)


if __name__ == '__main__':
    migrate = Migrate(app, db)

    manager = Manager(app)
    manager.add_command('db', MigrateCommand)
    manager.add_command('test', RunTests())
    manager.run()
