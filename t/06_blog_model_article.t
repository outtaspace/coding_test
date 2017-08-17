#!/usr/bin/perl

use lib::abs qw(../lib);

use Mojo::Base -strict;

use Mojo::Pg;
use Test::More;

plan tests => 3;

use_ok 'Blog::Model::Article';
require_ok 'Blog::Model::Article';

subtest 'new()' => sub {
    plan tests => 3;

    my $o = create_instance();

    ok $o;
    isa_ok $o, 'Mojo::Base';
    can_ok $o, qw(pg get update delete);
};

sub create_instance {

    my $pg = Mojo::Pg->new->dsn('dbi:Mock:');

    return Blog::Model::Article->new(pg => $pg);
}

