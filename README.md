Install all the deps for the current directory:
$ cpanm --installdeps .

Run database migrations:
$ ./rest_api.pl migrate

Run all tests with the command:
$ ./rest_api.pl test

Start application with HTTP and WebSocket server:
$ ./rest_api.pl daemon -m production -l http://*:8080
