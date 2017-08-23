#!/usr/bin/perl

use lib::abs qw(../lib);
use Mojo::Base -strict;

use Test::Mojo;
use Test::More;

use Blog::Test::Articles;
use Blog::Test::Article;
use Blog::Test::ArticleComment;

plan tests => 14;

my $t = Test::Mojo->new('Blog');

#-----------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------
subtest 'GET /blog/articles/' => sub {
    plan tests => 5;

    my $articles = Blog::Test::Articles->new;

    my $tx = $t->ua->build_tx(GET => $articles->url);

    $t->request_ok($tx)
        ->status_is(200)
        ->content_type_is('application/json;charset=UTF-8');

    my $json = $tx->res->json;

    if (ref $json eq 'ARRAY') {
        pass 'Contains array';

        if (@{ $json }) {
            my $article = $json->[0];
            ok(
                ref($article) eq 'HASH'
                && exists($article->{'id'})
                && defined($article->{'id'})
                && $article->{'id'} =~ m{^\d+$}x
            );
        }
        else {
            pass 'Array is empty';
        }
    }
    else {
        fail 'Not an array';
    }
};

#-----------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------
{
    my $article = create_article();

    $article = get_article($article);

    delete_article($article);
}

#-----------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------
subtest 'PUT /blog/articles/:article_id/' => sub {
    plan tests => 9;

    my $article = create_article();

    my $form = {name => 'Another name'};

    $t->put_ok($article->url, json => $form)
        ->status_is(200)
        ->content_type_is('application/json;charset=UTF-8')
        ->json_is({});

    my $updated = get_article($article);

    is $updated->id,   $article->id;
    is $updated->name, $form->{'name'};

    delete_article($article);
};

#-----------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------
{
    my $article = create_article();

    my $comment = create_comment($article, {});

    $comment = get_comment($comment);

    delete_comment($comment);
    delete_article($article);
}

#-----------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------
subtest 'foreign key' => sub {
    plan tests => 5;

    my $article = create_article();

    my $comment = create_comment($article, {});

    delete_article($article);

    $t->get_ok($comment->url)->status_is(404)
};

#-----------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------
subtest 'PUT /blog/comments/:comment_id/' => sub {
    plan tests => 13;

    my $article = create_article();

    my $comment = create_comment($article, {});

    $comment = get_comment($comment);

    my $form = {
        name    => 'Another comment name',
        comment => 'Another comment body',
    };

    $t->put_ok($comment->url, json => $form)
        ->status_is(200)
        ->content_type_is('application/json;charset=UTF-8')
        ->json_is({});

    my $updated = get_comment($comment);

    is $updated->id,         $comment->id;
    is $updated->article_id, $comment->article_id;
    is $updated->name,       $form->{'name'};
    is $updated->comment,    $form->{'comment'};

    delete_article($article);
};

#-----------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------
subtest 'GET /blog/articles/:article_id/comments/' => sub {
    plan tests => 13;

    my $article = create_article();

    my $comment_0_0 = create_comment($article, {parent_id => 0});
    my $comment_0_1 = create_comment($article, {parent_id => $comment_0_0->id});
    my $comment_0_2 = create_comment($article, {parent_id => $comment_0_0->id});

    my $comment_1_0 = create_comment($article, {parent_id => 0});
    my $comment_1_1 = create_comment($article, {parent_id => $comment_1_0->id});
    my $comment_1_2 = create_comment($article, {parent_id => $comment_1_0->id});

    my $comment_2_0 = create_comment($article, {parent_id => 0});


    my $json = do {
        my $tx = $t->ua->build_tx(GET => $article->comments_url);

        $t->request_ok($tx)
            ->status_is(200)
            ->content_type_is('application/json;charset=UTF-8');

        $tx->res->json;
    };

    is_deeply $json, [
        {
            id        => $comment_0_0->id,
            parent_id => $comment_0_0->parent_id,
        },
        {
            id        => $comment_0_1->id,
            parent_id => $comment_0_1->parent_id,
        },
        {
            id        => $comment_0_2->id,
            parent_id => $comment_0_2->parent_id,
        },
        {
            id        => $comment_1_0->id,
            parent_id => $comment_1_0->parent_id,
        },
        {
            id        => $comment_1_1->id,
            parent_id => $comment_1_1->parent_id,
        },
        {
            id        => $comment_1_2->id,
            parent_id => $comment_1_2->parent_id,
        },
        {
            id        => $comment_2_0->id,
            parent_id => $comment_2_0->parent_id,
        },
    ];

    delete_article($article);
};

#-----------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------
subtest 'GET /blog/articles/:article_id/comments_as_tree/' => sub {
    plan tests => 13;

    my $article = create_article();

    my $comment_0_0 = create_comment($article, {parent_id => 0});
    my $comment_0_1 = create_comment($article, {parent_id => $comment_0_0->id});
    my $comment_0_2 = create_comment($article, {parent_id => $comment_0_0->id});

    my $comment_1_0 = create_comment($article, {parent_id => 0});
    my $comment_1_1 = create_comment($article, {parent_id => $comment_1_0->id});
    my $comment_1_2 = create_comment($article, {parent_id => $comment_1_0->id});

    my $comment_2_0 = create_comment($article, {parent_id => 0});

    my $tx = $t->ua->build_tx(GET => $article->comments_as_tree_url);

    $t->request_ok($tx)
        ->status_is(200)
        ->content_type_is('application/json;charset=UTF-8');

    my $json = $tx->res->json;

    is_deeply $json, [
        {
            id        => $comment_0_0->id,
            parent_id => $comment_0_0->parent_id,
            comments  => [
                {
                    id        => $comment_0_1->id,
                    parent_id => $comment_0_1->parent_id,
                    comments  => [],
                },
                {
                    id        => $comment_0_2->id,
                    parent_id => $comment_0_2->parent_id,
                    comments  => [],
                },
            ],
        },
        {
            id        => $comment_1_0->id,
            parent_id => $comment_1_0->parent_id,
            comments  => [
                {
                    id        => $comment_1_1->id,
                    parent_id => $comment_1_1->parent_id,
                    comments  => [],
                },
                {
                    id        => $comment_1_2->id,
                    parent_id => $comment_1_2->parent_id,
                    comments  => [],
                },
            ],
        },
        {
            id        => $comment_2_0->id,
            parent_id => $comment_2_0->parent_id,
            comments  => [],
        },
    ];

    delete_article($article);
};

#-----------------------------------------------------------------------------------------
#-- subroutines --------------------------------------------------------------------------
sub create_article {
    my $articles     = Blog::Test::Articles->new;
    my $article_name = 'Article name';

    my $tx = $t->ua->build_tx(
        POST => $articles->url,
        json => {name => $article_name},
    );

    my $article_id;

    subtest 'create_article()' => sub {
        plan tests => 5;

        $t->request_ok($tx)
            ->status_is(201)
            ->content_type_is('application/json;charset=UTF-8')
            ->json_has('/id')
            ->json_like('/id' => qr{^\d+$});

        $article_id = $tx->res->json->{'id'};
    };

    return Blog::Test::Article->new(
        id   => $article_id,
        name => $article_name,
    );
}

sub get_article {
    my $article = shift;

    my ($article_id, $article_name);

    subtest 'get_article()' => sub {
        plan tests => 7;

        my $tx = $t->ua->build_tx(GET => $article->url);

        $t->request_ok($tx)
            ->status_is(200)
            ->content_type_is('application/json;charset=UTF-8')
            ->json_has('/id')
            ->json_is('/id' => $article->id)
            ->json_has('/name')
            ->json_like('/name' => qr{^.+$});

        {
            my $json = $tx->res->json;

            ($article_id, $article_name) = map { $json->{$_} } qw(id name);
        }
    };

    return Blog::Test::Article->new(
        id   => $article_id,
        name => $article_name,
    );
}

sub delete_article {
    my $article = shift;

    subtest 'delete_article()' => sub {
        plan tests => 6;

        $t->delete_ok($article->url)
            ->status_is(200)
            ->content_type_is('application/json;charset=UTF-8')
            ->json_is({});

        $t->get_ok($article->url)->status_is(404);
    };

    undef $article;
}

sub create_comment {
    my ($article, $form) = @_;

    $form->{'parent_id'} //= 0;
    $form->{'name'}      //= 'Comment name';
    $form->{'comment'}   //= 'Comment body';

    my $comment_id;

    subtest 'create_comment()' => sub {
        plan tests => 5;

        my $tx = $t->ua->build_tx(POST => $article->comments_url, json => $form);

        $t->request_ok($tx)
            ->status_is(201)
            ->content_type_is('application/json;charset=UTF-8')
            ->json_has('/id')
            ->json_like('/id' => qr{^\d+$}x);

        $comment_id = $tx->res->json->{'id'};
    };

    return Blog::Test::ArticleComment->new(
        id         => $comment_id,
        parent_id  => $form->{'parent_id'},
        name       => $form->{'name'},
        comment    => $form->{'comment'},
    );
}

sub get_comment {
    my $comment = shift;

    my $json;

    subtest 'get_comment()' => sub {
        plan tests => 13;

        my $tx = $t->ua->build_tx(GET => $comment->url);

        $t->request_ok($tx)
            ->status_is(200)
            ->content_type_is('application/json;charset=UTF-8')
            ->json_has('/id')
            ->json_like('/id' => qr{^\d+$}x)
            ->json_has('/article_id')
            ->json_like('/article_id' => qr{^\d+$}x)
            ->json_has('/parent_id')
            ->json_like('/parent_id' => qr{^\d+$}x)
            ->json_has('/name')
            ->json_like('/name' => qr{^.+$}x)
            ->json_has('/comment')
            ->json_like('/comment' => qr{^.+$}x);

        $json = $tx->res->json;
    };

    return Blog::Test::ArticleComment->new(
        id         => $json->{'id'},
        article_id => $json->{'article_id'},
        parent_id  => $json->{'parent_id'},
        name       => $json->{'name'},
        comment    => $json->{'comment'},
    );
}

sub delete_comment {
    my $comment = shift;

    subtest 'delete_comment()' => sub {
        plan tests => 6;

        $t->delete_ok($comment->url)
            ->status_is(200)
            ->content_type_is('application/json;charset=UTF-8')
            ->json_is({});

        $t->get_ok($comment->url)->status_is(404)
    };

    undef $comment;
}

#-----------------------------------------------------------------------------------------
#-- end ----------------------------------------------------------------------------------

