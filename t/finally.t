#!/usr/bin/perl

use strict;
use warnings;

use Test::More;

use Promise::XS;

my $def = Promise::XS::deferred();

$def->resolve(234);

my $p = $def->promise();

my ($args, $wantarray);

my $finally = $p->finally( sub {
    $args = \@_;
    $wantarray = wantarray;
    return 666;
} );

is_deeply( $args, [], 'no args given to finally() callback' );
is( $wantarray, q<>, 'finally() callback is called in scalar context' );

my $got;
$finally->then( sub { $got = \@_ } );

is_deeply( $got, [234], 'args to then() after a finally()' );

done_testing;

1;
