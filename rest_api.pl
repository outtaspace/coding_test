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
#-- /blog/articles/:article_id/comments --------------------------------------------------
get '/blog/articles/:article_id/comments' => sub {
    my $self = shift;

    my $article_id = $self->param('article_id');

    my $dbh = $self->app->dbh;
    $dbh->begin_work;

    if (is_article_exists($dbh, $article_id)) {
        my $comments = _fetch_all_comments_for($dbh, $article_id);

        $dbh->commit;
        $self->render(json => $comments);
    }
    else {
        $dbh->rollback;
        return $self->reply->not_found;
    }
};

get '/blog/articles/:article_id/comments/as_tree' => sub {
    my $self = shift;

    my $article_id = $self->param('article_id');

    my $dbh = $self->app->dbh;
    $dbh->begin_work;

    if (is_article_exists($dbh, $article_id)) {
        my $comments = _build_tree_of_comments($dbh, $article_id);

        $dbh->commit;
        $self->render(json => $comments);
    }
    else {
        $dbh->rollback;
        return $self->reply->not_found;
    }
};

post '/blog/articles/:article_id/comments' => sub {
    my $self = shift;

    my $json = $self->req->json;

    my $article_id = $self->param('article_id');
    my $parent_id  = $json->{'parent_id'};
    my $name       = $json->{'name'};
    my $comment    = $json->{'comment'};

    my $dbh = $self->app->dbh;
    $dbh->begin_work;

    if (is_article_exists($dbh, $article_id)) {
        $dbh->do(q{
            insert into article_comments (
                article_id,
                parent_id,
                name,
                `comment`
            )
            values (?, ?, ?, ?)
        }, undef, $article_id, $parent_id, $name, $comment);

        my $comment_id = $dbh->selectrow_array(q{select last_insert_id()});

        $dbh->commit;
        $self->render(json => {id => $comment_id}, status => 201);
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

sub _fetch_all_comments_for {
    my ($dbh, $article_id) = @_;

    return $dbh->selectall_arrayref(q{
        select
            ac.id,
            ac.parent_id
        from
            article_comments as ac
        where
            ac.article_id=?
    }, {Slice => {}}, $article_id);
}

sub _build_tree_of_comments {
    my ($dbh, $article_id) = @_;

    my %parent = (0 => []);

    for my $each_comment (@{ _fetch_all_comments_for($dbh, $article_id) }) {
        my $id        = $each_comment->{'id'};
        my $parent_id = $each_comment->{'parent_id'} // 0;

        $each_comment->{'comments'} = [];

        $parent{$id} = $each_comment->{'comments'};

        push @{ $parent{$parent_id} }, $each_comment;
    }

    return $parent{0};
}

#-----------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------
app->start;

