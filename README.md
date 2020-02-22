# NAME

Promise::XS - Fast promises in Perl

# SYNOPSIS

    use Promise::XS ();

    my $deferred = Promise::XS::deferred();

    # Do one of these once you have the result of your operation:
    $deferred->resolve( 'foo' );
    $deferred->reject( 'oh no!' );

    # Give this to your caller:
    my $promise = $deferred->promise();

The following aggregator functions are exposed:

    # Resolves with an arrayref, one item per promise.
    # Rejects with the results from the first rejected promise.
    my $all_p = Promise::XS::all( $promise1, $promise2, .. );

    # Resolves/rejects with the result from the first
    # resolved or rejected promise.
    my $race_p = Promise::XS::race( $promise3, $promise4, .. );

For compatibility with preexisting libraries, `all()` may also be called
as `collect()`.

The following also exist:

    my $pre_resolved_promise = Promise::XS::resolved('already done');

    my $pre_rejected_promise = Promise::XS::rejected('badbad');

All of `Promise::XS`’s static functions may be exported at load time,
e.g., `use Promise::XS qw(deferred)`.

# DESCRIPTION

This module exposes a Promise interface with its major parts
implemented in XS for speed. It is a fork and refactor of
[AnyEvent::XSPromises](https://metacpan.org/pod/AnyEvent::XSPromises), with some significant interface changes.

# STATUS

This module should be fairly stable but is still relatively untested since
the fork from [AnyEvent::XSPromises](https://metacpan.org/pod/AnyEvent::XSPromises). Significant breaking changes happened
from version 0.07 to 0.08. Such changes aren’t expected to be needed again,
but that’s not guaranteed. Caveat emptor.

# PROMISE INTERFACE

The core functionality derives from the
[Promises/A+ specification](https://promisesaplus.com/) standard. (See
["EVENT LOOPS"](#event-loops) below for one important difference.) Its `finally()`
implementation [derives from ECMAScript promises](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Promise/finally).

## Promise callbacks: list vs. scalar context

Most Perl promise libraries allow promises to resolve (or reject) with a list.
The problem with this pattern is: what do we do if a plural return includes
a promise? Neither Promises/A+ nor ECMAScript’s promise standard offers
guidance on how to handle this scenario, and there’s no “obvious” solution
otherwise. We could simply ignore the “extra” inputs, but what if one of those
“extras” is itself a promise? What if there’s only one promise, but it’s not
the first item returned?

All of these scenarios allow for subtle bugs to arise. To avoid that,
this library executes all callbacks in scalar context. Besides avoiding the
“problem” states described above, this also matches both Promises/A+ and
ECMAScript standards. The divergence from preexisting Perl promise libraries
like [Mojo::Promise](https://metacpan.org/pod/Mojo::Promise), [Promises](https://metacpan.org/pod/Promises), and [AnyEvent::XSPromises](https://metacpan.org/pod/AnyEvent::XSPromises), is
regrettable but seems a “lesser evil” overall.

## Additional notes

- Neither the `resolve()` method of deferred objects
nor the `resolved()` convenience function define behavior when given
a promise object.
- The `all()` and `race()` functions accept a list of promises,
not a “scalar-array-thing” (ECMAScript “arrays” being what in Perl we
call “array references”). So whereas in ECMAScript you do:

        Promise.all( [ promise1, promise2 ] );

    … in this library it’s:

        Promise::XS::all( $promise1, $promise2 );

- Currently `finally()` does not recognize returned promises.
Hopefully that will change in the future to match ECMAScript’s standard.

See [Promise::ES6](https://metacpan.org/pod/Promise::ES6) for an interface that imitates ECMAScript promises
more closely.

# EVENT LOOPS

By default this library uses no event loop. This is a perfectly usable
configuration; however, it’ll be a bit different from how promises usually
work in evented contexts (e.g., JavaScript) because callbacks will execute
immediately rather than at the end of the event loop as the Promises/A+
specification requires.

To achieve full Promises/A+ compliance it’s necessary to integrate with
an event loop interface. This library supports three such interfaces:

- [AnyEvent](https://metacpan.org/pod/AnyEvent):

        Promise::XS::use_event('AnyEvent');

- [IO::Async](https://metacpan.org/pod/IO::Async) - note the need for an [IO::Async::Loop](https://metacpan.org/pod/IO::Async::Loop) instance
as argument:

        Promise::XS::use_event('IO::Async', $loop_object);

- [Mojo::IOLoop](https://metacpan.org/pod/Mojo::IOLoop):

        Promise::XS::use_event('Mojo::IOLoop');

Note that all three of the above are event loop **interfaces**. They
aren’t event loops themselves, but abstractions over various event loops.
See each one’s documentation for details about supported event loops.

**REMINDER:** There’s no reason why promises _need_ an event loop; it
just satisfies the Promises/A+ convention.

# MEMORY LEAK DETECTION

Any promise created while `$Promise::XS::DETECT_MEMORY_LEAKS` is truthy
will throw a warning if it survives until global destruction.

# SUBCLASSING

You can re-bless a [Promise::XS::Promise](https://metacpan.org/pod/Promise::XS::Promise) instance into a different class,
and `then()`, `catch()`, and `finally()` will assign their newly-created
promise into that other class. (It follows that the other class must subclass
[Promise::XS::Promise](https://metacpan.org/pod/Promise::XS::Promise).) This can be useful, e.g., for implementing
mid-flight controls like cancellation.

# TODO

- `all()` and `race()` should be implemented in XS,
as should `resolved()` and `rejected()`.

# KNOWN ISSUES

- `finally()` ignores rejected promises given as returns rather than
rejecting the promise as should happen.
- Interpreter-based threads may or may not work.
- This module interacts badly with Perl’s fork() implementation on
Windows. There may be a workaround possible, but none is implemented for now.

# SEE ALSO

Besides [AnyEvent::XSPromises](https://metacpan.org/pod/AnyEvent::XSPromises) and [Promises](https://metacpan.org/pod/Promises), you may like [Promise::ES6](https://metacpan.org/pod/Promise::ES6),
which mimics [ECMAScript’s “Promise” class](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Promise) as much as possible.
It can even
(experimentally) use this module as a backend, which helps but is still
significantly slower than using this module directly.
