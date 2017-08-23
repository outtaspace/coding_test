Install all the deps for the current directory:
$ cpanm --installdeps .

Run database migrations:
$ ./bin/run.pl migrate

Run all tests with the command:
$ ./bin/run.pl test

Start application with HTTP and WebSocket server:
$ ./bin/run.pl daemon -l http://*:8080
