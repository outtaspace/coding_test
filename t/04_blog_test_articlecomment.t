#!/usr/bin/perl

use lib::abs qw(../lib);

use Mojo::Base -strict;
use Test::Mojo;
use Test::More;

plan tests => 4;

my $t = Test::Mojo->new('Blog');

use_ok 'Blog::Test::ArticleComment';
require_ok 'Blog::Test::ArticleComment';

subtest 'new()' => sub {
    plan tests => 5;

    my $o = Blog::Test::ArticleComment->new(app => $t->app);

    ok $o;
    isa_ok $o, 'Mojo::Base';
    can_ok $o, qw(
        app
        id
        article_id
        parent_id
        name
        comment
        get_article_comment
        update_article_comment
        delete_article_comment
    );

    isa_ok $o->app, 'Mojolicious';
    isa_ok $o->app, 'Blog';
};

subtest 'routes' => sub {
    plan tests => 3;

    my $o = Blog::Test::ArticleComment->new(
        app => $t->app,
        id  => 42,
    );

    is $o->get_article_comment,    '/blog/comments/42';
    is $o->update_article_comment, '/blog/comments/42';
    is $o->delete_article_comment, '/blog/comments/42';
};

