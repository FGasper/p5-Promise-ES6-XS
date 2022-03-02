#!/usr/bin/env perl

use strict;
use warnings;

use Test::More;

use Promise::XS;

use Test::FailWarnings -allow_deps => 1;

my $failed_why;

BEGIN {
    eval 'use IO::Async::Loop; 1' or $failed_why = $@;
}

plan skip_all => "Can’t run test: $failed_why" if $failed_why;

my $loop = IO::Async::Loop->new();

Promise::XS::use_event('IO::Async', $loop);

my $d = Promise::XS::deferred();

$loop->later( sub { $d->resolve(42, 34) } );

my @got = $d->promise()->AWAIT_WAIT();

is( "@got", "42 34", 'top-level await: success' );

done_testing;

