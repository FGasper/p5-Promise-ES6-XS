#!/usr/bin/env perl

use strict;
use warnings;

use Test::More;
#use Test::FailWarnings -allow_deps => 1;

use FindBin;
use lib "$FindBin::Bin/lib";
use AwaitWait;

diag sprintf "TOPMARK a: %d\n", Promise::XS::_TOPMARK();
Promise::XS::_SHOW_STACK();

use Promise::XS;

ok 1;

done_testing;


