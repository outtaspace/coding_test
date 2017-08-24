#!/usr/bin/perl

use lib::abs qw(../lib);

use Mojo::Base -strict;
use Test::Mojo;
use Test::More;

plan tests => 4;

my $t = Test::Mojo->new('Blog');

use_ok 'Blog::Test::Articles';
require_ok 'Blog::Test::Articles';

subtest 'new()' => sub {
    plan tests => 5;

    my $o = Blog::Test::Articles->new(app => $t->app);

    ok $o;
    isa_ok $o, 'Mojo::Base';
    can_ok $o, qw(app get_all_articles create_article);

    isa_ok $o->app, 'Mojolicious';
    isa_ok $o->app, 'Blog';
};

subtest 'routes' => sub {
    plan tests => 2;

    my $o = Blog::Test::Articles->new(app => $t->app);

    is $o->get_all_articles, '/blog/articles';
    is $o->create_article,   '/blog/articles';
};

