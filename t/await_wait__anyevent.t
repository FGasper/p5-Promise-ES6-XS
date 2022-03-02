#!/usr/bin/env perl

use strict;
use warnings;

use Test::More;
use Test::FailWarnings -allow_deps => 1;

printf "TOPMARK a: %d\n", Promise::XS::_TOPMARK();

use Promise::XS;

use FindBin;
use lib "$FindBin::Bin/lib";
use AwaitWait;

printf "TOPMARK b: %d\n", Promise::XS::_TOPMARK();

my $failed_why;
printf "TOPMARK c: %d\n", Promise::XS::_TOPMARK();

BEGIN {
    eval 'use AnyEvent; 1' or $failed_why = $@;
}

plan skip_all => "Can’t run test: $failed_why" if $failed_why;

AwaitWait::skip_if_bad_topmark();
#
#Promise::XS::use_event('AnyEvent');
#
#AwaitWait::test_success(
#    sub {
#        my $d = shift;
#        AnyEvent->timer(
#            after => 0.1, cb => sub { $d->resolve(42, 34) },
#        );
#    },
#);

ok 1;

done_testing;
