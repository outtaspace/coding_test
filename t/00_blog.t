#!/usr/bin/perl

use lib::abs qw(../lib);

use Mojo::Base -strict;
use Test::More;

plan tests => 3;

use_ok 'Blog';
require_ok 'Blog';

subtest 'new()' => sub {
    plan tests => 3;

    my $o = Blog->new;
    ok $o;
    isa_ok $o, 'Mojolicious';
    can_ok $o, qw(startup init_routes init_models);
};

