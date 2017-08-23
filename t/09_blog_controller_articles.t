#!/usr/bin/perl

use lib::abs qw(../lib);

use Mojo::Base -strict;
use Test::More;

plan tests => 2;

use_ok 'Blog::Controller::Articles';
require_ok 'Blog::Controller::Articles';

