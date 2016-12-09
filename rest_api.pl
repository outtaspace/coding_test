#!/usr/bin/perl

use Mojolicious::Lite;
use DBI;

plugin 'Config';

app->secrets(app->config->{'secrets'});

app->attr(dbh => sub {
    my $hashref = shift->config;

    return DBI->connect(@{ $hashref->{'dbh'} });
});

#-----------------------------------------------------------------------------------------
#-- /blog/articles -----------------------------------------------------------------------
get '/blog/articles' => sub {
    my $self = shift;

    $self->render(json => []);
};

post '/blog/articles' => sub {
    my $self = shift;

    $self->render(json => {id => 42}, status => 201);
};

#-----------------------------------------------------------------------------------------
#-- /blog/articles/:article_id -----------------------------------------------------------
put '/blog/articles/:article_id' => sub {
    my $self = shift;

    $self->render(json => {});
};

get '/blog/articles/:article_id' => sub {
    my $self = shift;

    $self->render(json => {id => 42, name => 'Article name'});
};

del '/blog/articles/:article_id' => sub {
    my $self = shift;

    $self->render(json => {});
};

#-----------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------
app->start;

