#!/usr/bin/env perl

use strict;
use warnings;

use Test::More;
#use Test::FailWarnings -allow_deps => 1;

use FindBin;
use lib "$FindBin::Bin/lib";
use AwaitWait;

diag sprintf "TOPMARK a: %d\n", Promise::XS::_TOPMARK();

use Promise::XS;

diag sprintf "TOPMARK b: %d\n", Promise::XS::_TOPMARK();

my $failed_why;
diag sprintf "TOPMARK c: %d\n", Promise::XS::_TOPMARK();

BEGIN {
    eval 'use AnyEvent; 1' or $failed_why = $@;
}

plan skip_all => "Can’t run test: $failed_why" if $failed_why;

diag "topmark bad? " . _topmark_is_bad();

Promise::XS::use_event('AnyEvent');

diag "topmark bad? " . _topmark_is_bad();
Promise::XS::_SHOW_STACK();
diag "topmark bad? " . _topmark_is_bad();

AwaitWait::test_success(
    sub {
        my $d = shift;
        AnyEvent->timer(
            after => 0.1, cb => sub { $d->resolve(42, 34) },
        );
    },
);

ok 1;

done_testing;

# ----------------------------------------------------------------------

sub _topmark_is_bad {
    my $tm = Promise::XS::_TOPMARK();

    return ($tm != 0);
}
