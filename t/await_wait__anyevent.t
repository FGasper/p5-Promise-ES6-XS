#!/usr/bin/env perl

use strict;
use warnings;

use Test::More;

use Promise::XS;

BEGIN {
    Promise::XS::PRINT_TOPMARK();
}

Promise::XS::PRINT_TOPMARK();

use Test::FailWarnings;

my $failed_why;

BEGIN {
    eval 'use AnyEvent; 1' or $failed_why = $@;
}

Promise::XS::PRINT_TOPMARK();

plan skip_all => "Can’t run test: $failed_why" if $failed_why;

Promise::XS::PRINT_TOPMARK();

Promise::XS::use_event('AnyEvent');

Promise::XS::PRINT_TOPMARK();

my $d = Promise::XS::deferred();

Promise::XS::PRINT_TOPMARK();

my $t = AnyEvent->timer(
    after => 0.1, cb => sub { $d->resolve(42, 34) },
);

Promise::XS::PRINT_TOPMARK();

my @got = $d->promise()->AWAIT_WAIT();
use Devel::Peek;
Dump @got;

is( "@got", "42 34", 'top-level await: success' );

done_testing;
