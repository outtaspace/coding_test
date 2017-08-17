#!/usr/bin/perl

use lib::abs qw(../lib);

use Mojo::Base -strict;

use Mojo::Pg;
use Test::More;

plan tests => 3;

use_ok 'Blog::Model::ArticleComments';
require_ok 'Blog::Model::ArticleComments';

subtest 'new()' => sub {
    plan tests => 3;

    my $o = create_instance();

    ok $o;
    isa_ok $o, 'Mojo::Base';
    can_ok $o, qw(pg all all_as_tree create);
};

sub create_instance {

    my $pg = Mojo::Pg->new->dsn('dbi:Mock:');

    return Blog::Model::ArticleComments->new(pg => $pg);
}

