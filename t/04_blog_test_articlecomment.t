#!/usr/bin/perl

use lib::abs qw(../lib);

use Mojo::Base -strict;
use Test::More;

plan tests => 4;

use_ok 'Blog::Test::ArticleComment';
require_ok 'Blog::Test::ArticleComment';

subtest 'new()' => sub {
    plan tests => 3;

    my $o = Blog::Test::ArticleComment->new;

    ok $o;
    isa_ok $o, 'Blog::Test::ArticleComments';
    can_ok $o, qw(url comment_id parent_id name comment);
};

subtest 'url()' => sub {
    plan tests => 1;

    my $o = Blog::Test::ArticleComment->new(
        comment_id => 42,
    );

    is $o->url, '/blog/comments/42/';
};

