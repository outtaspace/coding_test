#!/usr/bin/perl

use lib::abs qw(../lib);

use Mojo::Base -strict;
use Test::More;

plan tests => 6;

use_ok 'Blog::Test::Article';
require_ok 'Blog::Test::Article';

subtest 'new()' => sub {
    plan tests => 3;

    my $o = Blog::Test::Article->new;

    ok $o;
    isa_ok $o, 'Blog::Test::Articles';
    can_ok $o, qw(article_id name url comments_url);
};

subtest 'url()' => sub {
    plan tests => 1;

    my $o = Blog::Test::Article->new(
        article_id => 42,
    );

    is $o->url, '/blog/articles/42/';
};

subtest 'comments_url()' => sub {
    plan tests => 1;

    my $o = Blog::Test::Article->new(
        article_id => 42,
    );

    is $o->comments_url, '/blog/articles/42/comments/';
};

subtest 'comments_as_tree_url()' => sub {
    plan tests => 1;

    my $o = Blog::Test::Article->new(
        article_id => 42,
    );

    is $o->comments_as_tree_url, '/blog/articles/42/comments_as_tree/';
};

