#!/usr/bin/env perl

use strict;
use warnings;

use Test::More;
use Test::FailWarnings;

use Promise::XS;

{
last;
    my $abandoned;

    my $deferred = Promise::XS::deferred()->on_abandon( sub { $abandoned++ } );

    $deferred->promise();

    is($abandoned, 1, 'abandoned callback fires');
}

{
    my $abandoned;

    my $deferred = Promise::XS::deferred()->on_abandon( sub { $abandoned++ } );

# Tricky: We didn’t create a promise here, so there’s no DESTROY that fires
# when it’s reaped.
    $deferred->promise()->then( sub { print "hi!" } );
diag ("called then()");

    is($abandoned, 1, 'abandoned callback fires (chain)');
}
exit;

{
    my $abandoned;

    my $deferred = Promise::XS::deferred()->on_abandon( sub { $abandoned++ } );

    {
        my $p = $deferred->promise();

        $deferred->resolve(123);
    }

    is($abandoned, undef, 'abandoned callback does NOT fire if resolved');
}

{
    my $abandoned;

    my $deferred = Promise::XS::deferred()->on_abandon( sub { $abandoned++ } );

    {
        my $p = $deferred->promise()->catch( sub {} );

        $deferred->reject(123);
    }

    is($abandoned, undef, 'abandoned callback does NOT fire if rejected');
}

done_testing;

1;
