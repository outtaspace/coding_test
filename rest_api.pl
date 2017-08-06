#!/usr/bin/perl

use lib::abs qw(./lib);

use Mojolicious::Lite;
use Mojo::Pg;
use Try::Tiny;

plugin 'Config';

app->secrets(app->config->{'secrets'});

helper pg => sub {
    state $pg = Mojo::Pg->new(shift->config->{'pg_connection'});
};

#-----------------------------------------------------------------------------------------
#-- /blog/articles -----------------------------------------------------------------------
get '/blog/articles' => sub {
    my $self = shift;

    my $articles = $self->app->pg->db->select('blog.articles', [qw(id name)])->hashes;

    $self->render(json => $articles);
};

post '/blog/articles' => sub {
    my $self = shift;

    my $article_name = $self->req->json->{'name'};

    my $article_id = $self->app->pg->db->insert(
        'blog.articles',
        {name => $article_name},
        {returning => 'id'},
    )->hash->{'id'};

    $self->render(json => {id => $article_id}, status => 201);
};

#-----------------------------------------------------------------------------------------
#-- /blog/articles/:article_id -----------------------------------------------------------
put '/blog/articles/:article_id' => sub {
    my $self = shift;

    my $article_id   = $self->param('article_id');
    my $article_name = $self->req->json->{'name'};

    $article_id = $self->app->pg->db->update(
        'blog.articles',
        {name => $article_name},
        {id => $article_id},
        {returning => 'id'},
    )->hash->{'id'};

    return $self->reply->not_found unless $article_id;

    $self->render(json => {});
};

get '/blog/articles/:article_id' => sub {
    my $self = shift;

    my $article_id = $self->param('article_id');

    my $article = $self->app->pg->db->select(
        'blog.articles',
        [qw(id name)],
        {id => $article_id},
    )->hash;

    return $self->reply->not_found unless $article;

    $self->render(json => $article);
};

del '/blog/articles/:article_id' => sub {
    my $self = shift;

    my $article_id = $self->param('article_id');

    $article_id = $self->app->pg->db->delete(
        'blog.articles',
        {id => $article_id},
        {returning => 'id'},
    )->hash->{'id'};

    return $self->reply->not_found unless $article_id;

    $self->render(json => {});
};

#-----------------------------------------------------------------------------------------
#-- /blog/articles/:article_id/comments --------------------------------------------------
get '/blog/articles/:article_id/comments' => sub {
    my $self = shift;

    my $article_id = $self->param('article_id');

    my $comments;
    try {
        my $db = $self->app->pg->db;
        my $tx = $db->begin;

        if (is_article_exists($db, $article_id)) {
            $comments = _fetch_all_comments_for($db, $article_id);
        }

        $tx->commit;
    };

    return $self->reply->not_found unless $comments;

    $self->render(json => $comments);
};

get '/blog/articles/:article_id/comments/as_tree' => sub {
    my $self = shift;

    my $article_id = $self->param('article_id');

    my $comments;
    try {
        my $db = $self->app->pg->db;
        my $tx = $db->begin;

        if (is_article_exists($db, $article_id)) {
            $comments = _build_tree_of_comments($db, $article_id);
        }

        $tx->commit;
    };

    return $self->reply->not_found unless $comments;

    $self->render(json => $comments);
};

post '/blog/articles/:article_id/comments' => sub {
    my $self = shift;

    my $json = $self->req->json;

    my $article_id = $self->param('article_id');
    my $parent_id  = $json->{'parent_id'};
    my $name       = $json->{'name'};
    my $comment    = $json->{'comment'};

    my $comment_id;
    try {
        my $db = $self->app->pg->db;
        my $tx = $db->begin;

        if (is_article_exists($db, $article_id)) {
            $comment_id = $db->insert(
                'blog.article_comments',
                {
                    article_id => $article_id,
                    parent_id  => $parent_id,
                    name       => $name,
                    comment    => $comment,
                },
                {returning => 'id'},
            )->hash->{'id'};
        }

        $tx->commit;
    };

    return $self->reply->not_found unless $comment_id;

    $self->render(json => {id => $comment_id}, status => 201);
};

#-----------------------------------------------------------------------------------------
#-- /blog/articles/:article_id/comments/:comment_id --------------------------------------
get '/blog/articles/:article_id/comments/:comment_id' => sub {
    my $self = shift;

    my $article_id = $self->param('article_id');
    my $comment_id = $self->param('comment_id');

    my $comment = $self->app->pg->db->select(
        'blog.article_comments',
        [qw(id article_id parent_id name comment)],
        {article_id => $article_id, id => $comment_id},
    )->hash;

    return $self->reply->not_found unless $comment;

    $self->render(json => $comment);
};

put '/blog/articles/:article_id/comments/:comment_id' => sub {
    my $self = shift;

    my $article_id = $self->param('article_id');
    my $comment_id = $self->param('comment_id');

    my ($name, $comment);
    {
        my $json = $self->req->json;
        $name    = $json->{'name'};
        $comment = $json->{'comment'};
    }

    $comment_id = $self->app->pg->db->update(
        'blog.article_comments',
        {name => $name, comment => $comment},
        {article_id => $article_id, id => $comment_id},
        {returning => 'id'},
    )->hash->{'id'};

    return $self->reply->not_found unless $comment_id;

    $self->render(json => {});
};

del '/blog/articles/:article_id/comments/:comment_id' => sub {
    my $self = shift;

    my $article_id = $self->param('article_id');
    my $comment_id = $self->param('comment_id');

    $comment_id = $self->app->pg->db->delete(
        'blog.article_comments',
        {article_id => $article_id, id => $comment_id},
        {returning => 'id'},
    )->hash->{'id'};

    return $self->reply->not_found unless $comment_id;

    $self->render(json => {});
};

#-----------------------------------------------------------------------------------------
#-- start the Mojolicious command system -------------------------------------------------
app->start;

#-----------------------------------------------------------------------------------------
#-- subroutines --------------------------------------------------------------------------
sub is_article_exists {
    my ($db, $article_id) = @_;

    return $db->select(
        'blog.articles',
        ['id'],
        {id => $article_id},
    )->hash->{'id'} ? 1 : 0;
}

sub _fetch_all_comments_for {
    my ($db, $article_id) = @_;

    return $db->select(
        'blog.article_comments',
        [qw(id parent_id)],
        {article_id => $article_id},
    )->hashes;
}

sub _build_tree_of_comments {
    my ($db, $article_id) = @_;

    my %parent = (0 => []);

    for my $each_comment (@{ _fetch_all_comments_for($db, $article_id) }) {
        my $id        = $each_comment->{'id'};
        my $parent_id = $each_comment->{'parent_id'} // 0;

        $each_comment->{'comments'} = [];

        $parent{$id} = $each_comment->{'comments'};

        push @{ $parent{$parent_id} }, $each_comment;
    }

    return $parent{0};
}

#-----------------------------------------------------------------------------------------
#-- end ----------------------------------------------------------------------------------

