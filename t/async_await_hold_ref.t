#!/usr/bin/env perl

use strict;
use warnings;

use Test::More;
use Test::FailWarnings -allow_deps => 1;

printf "TOPMARK a: %d\n", Promise::XS::_TOPMARK();

if ($^V ge v5.16.0 && $^V le v5.25.0) {
    plan skip_all => "Future::AsyncAwait breaks on this perl ($^V). See https://rt.cpan.org/Public/Bug/Display.html?id=137723.";
}

printf "TOPMARK b: %d\n", Promise::XS::_TOPMARK();

use Promise::XS;

BEGIN {
printf "TOPMARK c: %d\n", Promise::XS::_TOPMARK();
    for my $req ( qw( Future::AsyncAwait  AnyEvent ) ) {
        eval "require $req" or plan skip_all => 'No Future::AsyncAwait';
    }

    eval { Future::AsyncAwait->VERSION(0.47) } or do {
        plan skip_all => "Future::AsyncAwait ($Future::AsyncAwait::VERSION) is too old.";
    };
printf "TOPMARK d: %d\n", Promise::XS::_TOPMARK();
}

use Future::AsyncAwait future_class => 'Promise::XS::Promise';

sub delay {
    my $secs = shift;

    my $d = Promise::XS::deferred();

    my $timer; $timer = AnyEvent->timer(
        after => $secs,
        cb => sub {
            undef $timer;
            $d->resolve($secs);
        },
    );

    return $d->promise();
}

async sub thethings {
    await delay(0.1);

    return 5;
}

printf "TOPMARK e: %d\n", Promise::XS::_TOPMARK();

my $cv = AnyEvent->condvar();
printf "TOPMARK f: %d\n", Promise::XS::_TOPMARK();

thethings()->then($cv);
printf "TOPMARK g: %d\n", Promise::XS::_TOPMARK();

my ($got) = $cv->recv();

is $got, 5, 'expected resolution';

done_testing;
