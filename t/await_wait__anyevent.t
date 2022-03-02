#!/usr/bin/env perl

use strict;
use warnings;

printf "# TOPMARK a: %d\n", Promise::XS::_TOPMARK();
Promise::XS::_SHOW_STACK();

use Promise::XS;

print "ok 1\n1..1\n";
