#!/usr/bin/perl

use lib::abs qw(../lib);

use Mojo::Base -strict;
use Test::Mojo;
use Test::More;

plan tests => 4;

my $t = Test::Mojo->new('Blog');

use_ok 'Blog::Test::Article';
require_ok 'Blog::Test::Article';

subtest 'new()' => sub {
    plan tests => 5;

    my $o = Blog::Test::Article->new(app => $t->app);

    ok $o;
    isa_ok $o, 'Mojo::Base';
    can_ok $o, qw(
        app
        id
        name
        get_article
        update_article
        delete_article
        create_article_comment
        get_all_article_comments
        get_all_article_comments_as_tree
    );

    isa_ok $o->app, 'Mojolicious';
    isa_ok $o->app, 'Blog';
};

subtest 'routes' => sub {
    plan tests => 6;

    my $o = Blog::Test::Article->new(
        app => $t->app,
        id  => 42,
    );

    is $o->get_article,                      '/blog/articles/42';
    is $o->update_article,                   '/blog/articles/42';
    is $o->delete_article,                   '/blog/articles/42';
    is $o->create_article_comment,           '/blog/articles/42/comments';
    is $o->get_all_article_comments,         '/blog/articles/42/comments';
    is $o->get_all_article_comments_as_tree, '/blog/articles/42/comments/as_tree';
};

