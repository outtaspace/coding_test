#!/usr/bin/perl

use Mojo::Base -strict;
use Test::Mojo;
use Test::More;
use FindBin;

plan tests => 10;

require $FindBin::Bin .'/../rest_api.pl';

my $t = Test::Mojo->new;

my ($article_id, $comment_id);

#-----------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------
subtest 'GET /blog/articles' => sub {
    plan tests => 5;

    my $tx = $t->ua->build_tx(GET => _articles_url());

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
subtest 'POST /blog/articles' => sub {
    plan tests => 4;

    my $form = {name => 'Article name'};

    my $tx = $t->ua->build_tx(POST => _articles_url() => json => $form);

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

#-----------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------
subtest 'PUT /blog/articles/:article_id' => sub {
    plan tests => 4;

    my $form = {name => 'Another name'};

    $t->put_ok(_article_url() => json => $form)
        ->status_is(200)
        ->content_type_is('application/json;charset=UTF-8')
        ->json_is({});
};

#-----------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------
subtest 'GET /blog/articles/:article_id' => sub {
    plan tests => 4;

    $t->get_ok(_article_url())
        ->status_is(200)
        ->content_type_is('application/json;charset=UTF-8')
        ->json_is('/id' => $article_id, '/name' => 'Another name');
};

#-----------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------
subtest 'DELETE /blog/articles/:article_id' => sub {
    plan tests => 4;

    $t->delete_ok(_article_url())
        ->status_is(200)
        ->content_type_is('application/json;charset=UTF-8')
        ->json_is({});
};

#-----------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------
_create_article();

subtest 'GET /blog/articles/:article_id/comments' => sub {
    plan tests => 5;

    my $tx = $t->ua->build_tx(GET => _comments_url());

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
                && exists($article->{'parent_id'})
                && defined($article->{'parent_id'})
                && $article->{'parent_id'} =~ m{^\d+$}x
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
subtest 'GET /blog/articles/:article_id/comments/as_tree' => sub {
    my $tx = $t->ua->build_tx(GET => _comments_as_tree_url());

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
                && exists($article->{'parent_id'})
                && defined($article->{'parent_id'})
                && $article->{'parent_id'} =~ m{^\d+$}x
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
subtest 'POST /blog/articles/:article_id/comments' => sub {
    plan tests => 4;


    my $form = {
        parent_id => 0,
        name      => 'Comment name',
        comment   => 'Comment body',
    };

    my $tx = $t->ua->build_tx(POST => _comments_url() => json => $form);

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

_delete_article();

#-----------------------------------------------------------------------------------------
#-- subroutines --------------------------------------------------------------------------
sub _articles_url {
    return '/blog/articles'
}

sub _article_url {
    return sprintf '%s/%d', _articles_url(), $article_id;
}

sub _comments_url {
    return sprintf '%s/comments', _article_url();
}

sub _comments_as_tree_url {
    return sprintf '%s/comments/as_tree', _article_url();
}

sub _comment_url {
    return sprintf '%s/%d', _comments_url(), $comment_id;
}

sub _create_article {
    my $form = {name => 'Article name'};

    my $tx = $t->ua->build_tx(POST => _articles_url() => json => $form);
    $t->request_ok($tx);

    my $json = $tx->res->json;

    $article_id = $json->{'id'};
}

sub _delete_article {
    my $form = {name => 'Article name'};

    my $tx = $t->ua->build_tx(DELETE => _article_url());
    $t->request_ok($tx);

    undef $article_id;
}

#-----------------------------------------------------------------------------------------
#-- end ----------------------------------------------------------------------------------

