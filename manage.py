from app import app, db
from flask_migrate import Migrate, MigrateCommand
from flask_script import Manager

if __name__ == '__main__':
    migrate = Migrate(app, db)

    manager = Manager(app)
    manager.add_command('db', MigrateCommand)
    manager.run()
