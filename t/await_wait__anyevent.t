#!/usr/bin/env perl

use strict;
use warnings;

use Test::More;

use Promise::XS;

use Test::FailWarnings;

my $failed_why;

BEGIN {
    eval 'use AnyEvent; 1' or $failed_why = $@;
}

plan skip_all => "Can’t run test: $failed_why" if $failed_why;

Promise::XS::use_event('AnyEvent');

my $d = Promise::XS::deferred();

my $t = AnyEvent->timer(
    after => 0.1, cb => sub { $d->resolve(42, 34) },
);

my @got = $d->promise()->AWAIT_WAIT();
use Devel::Peek;
Dump @got;

is( "@got", "42 34", 'top-level await: success' );

done_testing;
