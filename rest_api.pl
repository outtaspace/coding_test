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

    my $articles = $self->app->dbh->selectall_arrayref(q{
        select
            a.id
        from
            articles as a
    }, {Slice => {}});

    $self->render(json => $articles);
};

post '/blog/articles' => sub {
    my $self = shift;

    my $article_name = $self->req->json->{'name'};

    my $article_id;
    {
        my $dbh = $self->app->dbh;

        $dbh->begin_work;

        $self->app->dbh->do(q{
            insert into articles (name)
            values (?)
        }, undef, $article_name);

        $article_id = $dbh->selectrow_array(q{select last_insert_id()});

        $dbh->commit;
    }

    $self->render(json => {id => $article_id}, status => 201);
};

#-----------------------------------------------------------------------------------------
#-- /blog/articles/:article_id -----------------------------------------------------------
put '/blog/articles/:article_id' => sub {
    my $self = shift;

    my $article_id   = $self->param('article_id');
    my $article_name = $self->req->json->{'name'};

    $self->render(json => {});

    my $dbh = $self->app->dbh;
    $dbh->begin_work;

    if (is_article_exists($dbh, $article_id)) {
        $dbh->do(q{
            update
                articles
            set
                name=?
            where
                id=?
        }, undef, $article_name, $article_id);

        $dbh->commit;
        return $self->render(json => {});
    }
    else {
        $dbh->rollback;
        return $self->reply->not_found;
    }
};

get '/blog/articles/:article_id' => sub {
    my $self = shift;

    my $article_id = $self->param('article_id');

    my $dbh = $self->app->dbh;
    $dbh->begin_work;

    if (is_article_exists($dbh, $article_id)) {
        my $article = $dbh->selectrow_hashref(q{
            select
                a.id,
                a.name
            from
                articles as a
            where
                a.id=?
        }, undef, $article_id);

        $dbh->commit;
        $self->render(json => $article);
    }
    else {
        $dbh->rollback;
        return $self->reply->not_found;
    }
};

del '/blog/articles/:article_id' => sub {
    my $self = shift;

    my $article_id = $self->param('article_id');

    my $dbh = $self->app->dbh;
    $dbh->begin_work;

    if (is_article_exists($dbh, $article_id)) {
        $self->app->dbh->do(q{
            delete from
                articles
            where
                id=?
        }, undef, $article_id);

        $dbh->commit;
        $self->render(json => {});
    }
    else {
        $dbh->rollback;
        return $self->reply->not_found;
    }
};

#-----------------------------------------------------------------------------------------
#-- subroutines --------------------------------------------------------------------------
sub is_article_exists {
    my ($dbh, $article_id) = @_;

    return int $dbh->selectrow_array(q{
        select exists(
            select a.* from articles as a where a.id=?
        )
    }, undef, $article_id);
}

#-----------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------
app->start;

