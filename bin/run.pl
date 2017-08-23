#!/usr/bin/perl

use lib::abs qw(../lib);
use Mojo::Base -strict;

use Mojolicious::Commands;

# Start command line interface for application
Mojolicious::Commands->start_app('Blog');

