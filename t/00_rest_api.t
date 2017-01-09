#!/usr/bin/perl

use Mojo::Base -strict;
use lib::abs qw(../lib);
use Test::Mojo;
use Test::More;

use TestArticle;
use TestArticleComments;

plan tests => 14;

require (lib::abs::path('../rest_api.pl'));

my $t = Test::Mojo->new;

my ($article_id, $comment_id);

#-----------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------
subtest 'GET /blog/articles' => sub {
    plan tests => 5;

    my $tx = $t->ua->build_tx(GET => TestArticle->articles_url);

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
subtest 'PUT /blog/articles/:article_id' => sub {
    plan tests => 9;

    my $article = create_article();

    my $form = {name => 'Another name'};

    $t->put_ok($article->article_url, json => $form)
        ->status_is(200)
        ->content_type_is('application/json;charset=UTF-8')
        ->json_is({});

    my $updated = get_article($article);

    is $updated->article_id, $article->article_id;
    is $updated->name,       $form->{'name'};

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

    $t->get_ok($comment->comment_url)->status_is(404)
};

#-----------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------
subtest 'PUT /blog/articles/:article_id/comments/:comment_id' => sub {
    plan tests => 14;

    my $article = create_article();

    my $comment = create_comment($article, {});

    $comment = get_comment($comment);

    my $form = {
        parent_id => 0,
        name      => 'Another comment name',
        comment   => 'Another comment body',
    };

    $t->put_ok($comment->comment_url, json => $form)
        ->status_is(200)
        ->content_type_is('application/json;charset=UTF-8')
        ->json_is({});

    my $updated = get_comment($comment);

    is $updated->article->article_id, $comment->article->article_id;

    is $updated->comment_id, $comment->comment_id;

    is $updated->parent_id,  $form->{'parent_id'};
    is $updated->name,       $form->{'name'};
    is $updated->comment,    $form->{'comment'};

    delete_article($article);
};

#-----------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------
subtest 'GET /blog/articles/:article_id/comments' => sub {
    plan tests => 13;


    my $article = create_article();


    my $comment_0_0 = create_comment($article, {parent_id => 0});
    my $comment_0_1 = create_comment($article, {parent_id => $comment_0_0->comment_id});
    my $comment_0_2 = create_comment($article, {parent_id => $comment_0_0->comment_id});

    my $comment_1_0 = create_comment($article, {parent_id => 0});
    my $comment_1_1 = create_comment($article, {parent_id => $comment_1_0->comment_id});
    my $comment_1_2 = create_comment($article, {parent_id => $comment_1_0->comment_id});

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
            id        => $comment_0_0->comment_id,
            parent_id => $comment_0_0->parent_id,
        },
        {
            id        => $comment_0_1->comment_id,
            parent_id => $comment_0_1->parent_id,
        },
        {
            id        => $comment_0_2->comment_id,
            parent_id => $comment_0_2->parent_id,
        },
        {
            id        => $comment_1_0->comment_id,
            parent_id => $comment_1_0->parent_id,
        },
        {
            id        => $comment_1_1->comment_id,
            parent_id => $comment_1_1->parent_id,
        },
        {
            id        => $comment_1_2->comment_id,
            parent_id => $comment_1_2->parent_id,
        },
        {
            id        => $comment_2_0->comment_id,
            parent_id => $comment_2_0->parent_id,
        },
    ];

    delete_article($article);
};

#-----------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------
subtest 'GET /blog/articles/:article_id/comments/as_tree' => sub {
    plan tests => 13;


    my $article = create_article();


    my $comment_0_0 = create_comment($article, {parent_id => 0});
    my $comment_0_1 = create_comment($article, {parent_id => $comment_0_0->comment_id});
    my $comment_0_2 = create_comment($article, {parent_id => $comment_0_0->comment_id});

    my $comment_1_0 = create_comment($article, {parent_id => 0});
    my $comment_1_1 = create_comment($article, {parent_id => $comment_1_0->comment_id});
    my $comment_1_2 = create_comment($article, {parent_id => $comment_1_0->comment_id});

    my $comment_2_0 = create_comment($article, {parent_id => 0});


    my $tx = $t->ua->build_tx(GET => $article->comments_as_tree_url);

    $t->request_ok($tx)
        ->status_is(200)
        ->content_type_is('application/json;charset=UTF-8');

    my $json = $tx->res->json;

    is_deeply $json, [
        {
            id        => $comment_0_0->comment_id,
            parent_id => $comment_0_0->parent_id,
            comments  => [
                {
                    id        => $comment_0_1->comment_id,
                    parent_id => $comment_0_1->parent_id,
                    comments  => [],
                },
                {
                    id        => $comment_0_2->comment_id,
                    parent_id => $comment_0_2->parent_id,
                    comments  => [],
                },
            ],
        },
        {
            id        => $comment_1_0->comment_id,
            parent_id => $comment_1_0->parent_id,
            comments  => [
                {
                    id        => $comment_1_1->comment_id,
                    parent_id => $comment_1_1->parent_id,
                    comments  => [],
                },
                {
                    id        => $comment_1_2->comment_id,
                    parent_id => $comment_1_2->parent_id,
                    comments  => [],
                },
            ],
        },
        {
            id        => $comment_2_0->comment_id,
            parent_id => $comment_2_0->parent_id,
            comments  => [],
        },
    ];


    delete_article($article);
};

#-----------------------------------------------------------------------------------------
#-- subroutines --------------------------------------------------------------------------
sub create_article {
    my $article_name = 'Article name';

    my $form = {name => $article_name};
    my $url  = TestArticle->articles_url;

    my $tx = $t->ua->build_tx(POST => $url, json => $form);

    my $article_id;

    subtest 'create_article()' => sub {
        plan tests => 4;

        $t->request_ok($tx)
            ->status_is(201)
            ->content_type_is('application/json;charset=UTF-8');

        my $json = $tx->res->json;

        ok(
            ref($json) eq 'HASH'
            && exists($json->{'id'})
            && defined($json->{'id'})
            && $json->{'id'} =~ m{^\d+$}x
        );

        $article_id = $json->{'id'};
    };

    return TestArticle->new(
        article_id => $article_id,
        name       => $article_name,
    );
}

sub get_article {
    my $article = shift;

    my ($article_id, $article_name);

    subtest 'get_article()' => sub {
        my $tx = $t->ua->build_tx(GET => $article->article_url);

        $t->request_ok($tx)
            ->status_is(200)
            ->content_type_is('application/json;charset=UTF-8');

        my $json = $tx->res->json;

        ok(
            ref($json) eq 'HASH'
            && exists($json->{'id'})
            && defined($json->{'id'})
            && $json->{'id'} =~ m{^\d+$}x
        );

        ok(
            ref($json) eq 'HASH'
            && exists($json->{'name'})
            && defined($json->{'name'})
            && length($json->{'name'})
        );

        ($article_id, $article_name) = map { $json->{$_} } qw(id name);
    };

    return TestArticle->new(
        article_id => $article_id,
        name       => $article_name,
    );
}

sub delete_article {
    my $article = shift;

    subtest 'delete_article()' => sub {
        plan tests => 6;

        $t->delete_ok($article->article_url)
            ->status_is(200)
            ->content_type_is('application/json;charset=UTF-8')
            ->json_is({});

        $t->get_ok($article->article_url)->status_is(404)
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
        plan tests => 4;

        my $tx = $t->ua->build_tx(POST => $article->comments_url, json => $form);

        $t->request_ok($tx)
            ->status_is(201)
            ->content_type_is('application/json;charset=UTF-8');

        my $json = $tx->res->json;

        ok(
            ref($json) eq 'HASH'
            && exists($json->{'id'})
            && defined($json->{'id'})
            && $json->{'id'} =~ m{^\d+$}x
        );

        $comment_id = $json->{'id'};
    };

    return TestArticleComments->new(
        article    => $article,
        comment_id => $comment_id,
        parent_id  => $form->{'parent_id'},
        name       => $form->{'name'},
        comment    => $form->{'comment'},
    );
}

sub get_comment {
    my $comment = shift;

    my $json;

    subtest 'get_comment()' => sub {
        plan tests => 9;

        my $tx = $t->ua->build_tx(GET => $comment->comment_url);

        $t->request_ok($tx)
            ->status_is(200)
            ->content_type_is('application/json;charset=UTF-8');

        $json = $tx->res->json;

        ok(
            ref($json) eq 'HASH'
            && exists($json->{'id'})
            && defined($json->{'id'})
            && $json->{'id'} =~ m{^\d+$}x
        );

        ok(
            ref($json) eq 'HASH'
            && exists($json->{'article_id'})
            && defined($json->{'article_id'})
            && $json->{'article_id'} =~ m{^\d+$}x
        );

        ok(
            ref($json) eq 'HASH'
            && exists($json->{'parent_id'})
            && defined($json->{'parent_id'})
            && $json->{'parent_id'} =~ m{^\d+$}x
        );

        ok(
            ref($json) eq 'HASH'
            && exists($json->{'name'})
            && defined($json->{'name'})
            && length($json->{'name'})
        );

        ok(
            ref($json) eq 'HASH'
            && exists($json->{'comment'})
            && defined($json->{'comment'})
            && length($json->{'comment'})
        );

        is $json->{'article_id'}, $comment->article->article_id;
    };

    return TestArticleComments->new(
        article    => $comment->article,
        comment_id => $json->{'id'},
        parent_id  => $json->{'parent_id'},
        name       => $json->{'name'},
        comment    => $json->{'comment'},
    );
}

sub delete_comment {
    my $comment = shift;

    subtest 'delete_comment()' => sub {
        plan tests => 6;

        $t->delete_ok($comment->comment_url)
            ->status_is(200)
            ->content_type_is('application/json;charset=UTF-8')
            ->json_is({});

        $t->get_ok($comment->comment_url)->status_is(404)
    };

    undef $comment;
}

#-----------------------------------------------------------------------------------------
#-- end ----------------------------------------------------------------------------------

