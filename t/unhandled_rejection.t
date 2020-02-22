#!/usr/bin/perl

package t::unhandled_rejection;

use strict;
use warnings;

use Test::More;
use Test::Deep;
use Test::FailWarnings;

use Promise::XS;

# should not warn because catch() silences
{
    my $d = Promise::XS::deferred();

    my $p = $d->promise()->catch( sub { } );

    $d->reject("nonono");
}

{
    my @w;
    local $SIG{'__WARN__'} = sub { push @w, @_ };

    {
        my $d = Promise::XS::deferred();

        my $p = $d->promise();

        $p->then( sub {
            die "nonono";
        } );

        $d->resolve(234);
    }

    cmp_deeply(
        \@w,
        [ re( qr<nonono> ) ],
        'die() in then() triggers warning when promise was never an SV',
    ) or diag explain \@w;
}

{
    my @w;
    local $SIG{'__WARN__'} = sub { push @w, @_ };

    {
        my $d = Promise::XS::deferred();

        my $p = $d->promise();

        my $p2 = $p->then( sub {
            die "nonono";
        } );

        undef $p2;

        $d->resolve(234);
    }

    cmp_deeply(
        \@w,
        [ re( qr<nonono> ) ],
        'die() in then() triggers warning when promise was an SV that’s GCed early',
    );
}

{
    my @w;
    local $SIG{'__WARN__'} = sub { push @w, @_ };

    {
        my $d = Promise::XS::deferred();

        my $p = $d->promise();

        $p->then( sub {
            return Promise::XS::rejected(666);
        } );

        $d->resolve(234);
    }

    cmp_deeply(
        \@w,
        [ re( qr<666> ) ],
        'return rejected in then() triggers warning when promise itself never was an SV',
    );
}

{
    my @w;
    local $SIG{'__WARN__'} = sub { push @w, @_ };

    {
        my $d = Promise::XS::deferred();

        $d->reject("nonono");
    }

    cmp_deeply(
        \@w,
        [],
        'no warning if there was never a perl-ified promise',
    ) or diag explain \@w;
}

# should warn because finally() rejects
{
diag "===============================";
    my @w;
    local $SIG{'__WARN__'} = sub { push @w, @_ };

    {
        my $d = Promise::XS::deferred();

diag "creation of 2 promises; 1 should reap";
        my $p = $d->promise()->finally( sub { } );
diag "1 should have reaped by now";

        $d->reject("nonono");
    }

    cmp_deeply(
        \@w,
        [ re( qr<nonono> ) ],
        'rejection with no catch triggers warning',
    ) or diag explain \@w;
}

# should warn because finally() rejects
{
    my @w;
    local $SIG{'__WARN__'} = sub { push @w, @_ };

    {
        my $d = Promise::XS::deferred();

        my $p = $d->promise();

        my $f = $p->finally( sub { } );

        $p->catch( sub { } );

        diag "before reject";
        $d->reject("nonono");
        diag "after reject";
    }

    cmp_deeply(
        \@w,
        [ re( qr<nonono> ) ],
        'rejected finally is uncaught',
    ) or diag explain \@w;
}

# should NOT warn because finally() rejection is caught
{
    my @w;
    local $SIG{'__WARN__'} = sub { push @w, @_ };

    {
        my $d = Promise::XS::deferred();

        my $p = $d->promise();

        diag "created p1";

        my $f = $p->finally( sub { } );

        diag "created finally";

        $f = $f->catch( sub { } );

        diag "created catch, reaped finally";

        $p->catch( sub { } );

        diag "created & reaped 2nd catch";

        $d->reject("awful");
    }

    cmp_deeply(
        \@w,
        [],
        'no warning when finally passthrough rejection is caught',
    ) or diag explain \@w;
}

#----------------------------------------------------------------------

{
    my $d = Promise::XS::deferred();

    my $p = $d->resolve(123)->promise()->then( sub {
        my ($value) = @_;

        return Promise::XS::rejected( { message => 'oh my god', value => $value } );
    })->catch(sub {
        my ($reason) = @_;
        return $reason;
    });

    my $got;

    $p->then( sub { $got = shift } );

    is_deeply $got, { message => 'oh my god', value => 123 }, 'got expected';
}

#----------------------------------------------------------------------

{
    my $d = Promise::XS::deferred();

    my $p = $d->resolve(123)->promise()->then( sub {
        my ($value) = @_;

        return bless [], 'ForeignRejectedPromise';
    })->catch(sub {
        my ($reason) = @_;
        return $reason;
    });

    my $got;

    $p->then( sub { $got = shift } );

    is_deeply $got, 'ForeignRejectedPromise', 'got expected from foreign rejected';
}

#----------------------------------------------------------------------

done_testing();

#----------------------------------------------------------------------

package ForeignRejectedPromise;

sub then {
    my ($self, $on_res, $on_rej) = @_;

    $on_rej->(ref $self);

    return $self;
}

1;
