package AwaitWait;

use Test::More;

use Promise::XS;

sub skip_if_bad_topmark {
    my $tm = Promise::XS::_TOPMARK();

    if ($tm != 0) {
        plan skip_all => "TOPMARK is $tm, expected 0; skipping test …";
    }
}

sub test_success {
Promise::XS::_SHOW_STACK("before deferred");
    my $d = Promise::XS::deferred();
Promise::XS::_SHOW_STACK("after deferred");

    my @timer_state = shift->($d);
Promise::XS::_SHOW_STACK("after timer");

    my @got = $d->promise()->AWAIT_WAIT();

    is( "@got", "42 34", 'top-level await: success' );

    return;
}

1;
