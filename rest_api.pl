#!/usr/bin/perl

use Mojolicious::Lite;
use DBI;

plugin 'Config';

app->secrets(app->config->{'secrets'});

app->attr(dbh => sub {
    my $hashref = shift->config;

    return DBI->connect(@{ $hashref->{'dbh'} });
});

get '/article/comments' => sub {
    my $self = shift;

    {
        my $validation = $self->validation;
        $validation->required('article_id')->like(qr{^\d+$}x);

        return $self->render(json => {status => 422}, status => 422)
            if $validation->has_error;
    }

    my $sth = $self->app->dbh->prepare(q{
        select
            id, parent_id, user_id, comment
        from
            comments
        where
            article_id = ?
        order by
            id, parent_id
    });
    $sth->execute($self->param('article_id'));

    my $comments = [
        {
            id        => '1',
            parent_id => '0',
            comment   => 'Hello',
            comments => [
                {
                    id        => '2',
                    parent_id => '1',
                    comment   => 'Hello_1_0',
                    comments  => [
                        {
                            id        => '4',
                            parent_id => '1',
                            comment   => 'Hello_2_0',
                            comments  => [],
                        },
                        {
                            id        => '5',
                            parent_id => '1',
                            comment   => 'Hello_2_1',
                            comments  => [],
                        },
                    ],
                },
                {
                    id        => '3',
                    parent_id => '1',
                    comment   => 'Hello_1_1',
                    comments  => [
                        {
                            id        => '6',
                            parent_id => '1',
                            comment   => 'Hello_3_0',
                            comments  => [],
                        },
                        {
                            id        => '7',
                            parent_id => '1',
                            comment   => 'Hello_3_1',
                            comments  => [],
                        },
                    ],
                },
            ],
        },
        {
            id        => '8',
            parent_id => '0',
            comment   => q{Now I'm Here},
            comments  => [],
        },
    ];

    $self->render(json => {status => 200, comments => $comments});
};

post '/article/comment/create' => sub {
    my $self = shift;

    {
        my $validation = $self->validation;
        $validation->optional('parent_id')->like(qr{^\d+$}x);
        $validation->required('comment');
        $validation->required('article_id')->like(qr{^\d+$}x);
        $validation->required('user_id')->like(qr{^\d+$}x);

        return $self->render(json => {status => 422}, status => 422)
            if $validation->has_error;
    }

    my ($comment_id) = do {
        my $parent_id = $self->param('parent_id') // 0;
        my $comment   = $self->param('comment')   // q{};

        my $dbh = $self->app->dbh;

        $dbh->begin_work();

        $dbh->do(q{
            insert into `comments` (`parent_id`, `comment`, `article_id`, `user_id`)
            values (?, ?, ?, ?);
        }, undef, $parent_id, $comment, map { $self->param($_) } qw(article_id user_id));

        my $sth = $dbh->prepare(q{select last_insert_id();});
        $sth->execute();

        $dbh->commit();

        $sth->fetchrow_array();
    };

    $self->render(json => {status => 200, comment_id => $comment_id});
};

post '/article/comment/delete' => sub {
    my $self = shift;

    {
        my $validation = $self->validation;
        $validation->required('id')->like(qr{^\d+$}x);

        return $self->render(json => {status => 422}, status => 422)
            if $validation->has_error;
    }

    $self->app->dbh->do(q{delete from comments where id=?}, undef, $self->param('id'));

    $self->render(json => {status => 200});
};

app->start;
