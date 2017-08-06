package Mojolicious::Command::migrate;

use Mojo::Base 'Mojolicious::Command';
use Mojo::Pg::Migrations;

has description => 'Load migrations from file and migrate to latest version';
has usage       => "Usage: APPLICATION migrate\n";

sub run {
    my ($self) = @_;

    my $migrations = Mojo::Pg::Migrations->new(
        pg => Mojo::Pg->new($self->app->config->{'pg_connection'}),
    );

    my $sql_file = $self->app->home->child('migrations', 'migrate.sql');

    $migrations->from_file($sql_file)->migrate;
}

1;

