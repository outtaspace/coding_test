#!/usr/bin/perl

use lib::abs qw(../lib);

use Mojo::Base -strict;
use Test::More;

plan tests => 4;

use_ok 'Blog::Test::ArticleComments';
require_ok 'Blog::Test::ArticleComments';

subtest 'new()' => sub {
    plan tests => 3;

    my $o = Blog::Test::ArticleComments->new;

    ok $o;
    isa_ok $o, 'Mojo::Base';
    can_ok $o, qw(url);
};

subtest 'url()' => sub {
    plan tests => 1;

    my $o = Blog::Test::ArticleComments->new;

    is $o->url, '/blog/comments/';
};

