package Promise::XS::Promise;

use strict;
use warnings;

=encoding utf-8

=head1 NAME

Promise::XS::Promise - promise object

=head1 SYNOPSIS

See L<Promise::XS>.

=head1 DESCRIPTION

This is L<Promise::XS>’s actual promise object class. It implements
these methods:

=over

=item * C<then()>

=item * C<catch()>

=item * C<finally()>

=back

… which behave as they normally do in promise implementations.

=cut

sub _warn_unhandled {
    my ($promise_sv, $reason) = @_;

    warn "$promise_sv: Unhandled rejection: $reason\n";

    return;
}

1;
