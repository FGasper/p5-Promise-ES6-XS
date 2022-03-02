#!/usr/bin/env perl

#use strict;
#use warnings;

use Promise::XS;

BEGIN {
    Promise::XS::_SHOW_STACK("BEGIN");
}

Promise::XS::_SHOW_STACK("RUN");

my $d = Promise::XS::deferred();

$d->promise()->then(sub {
    Promise::XS::_SHOW_STACK("in callback");
});

$d->resolve(888);

print "ok 1\n1..1\n";
