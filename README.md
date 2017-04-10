# Log::WarnDie

Log standard Perl warnings and errors on a log handler

# SYNOPSIS

    use Log::WarnDie; # install to be used later

    my $dispatcher = Log::Dispatch->new;       # can be any dispatcher!
    $dispatcher->add( Log::Dispatch::Foo->new( # whatever output you like
     name      => 'foo',
     min_level => 'info',
    ) );

    use Log::WarnDie $dispatcher; # activate later

    Log::WarnDie->dispatcher( $dispatcher ); # same

    warn "This is a warning";       # now also dispatched
    die "Sorry it didn't work out"; # now also dispatched

    no Log::WarnDie; # deactivate later

    Log::WarnDie->dispatcher( undef ); # same

    warn "This is a warning"; # no longer dispatched
    die "Sorry it didn't work out"; # no longer dispatched

# VERSION

This documentation describes version 0.05.

# DESCRIPTION

The "Log::WarnDie" module offers a logging alternative for standard
Perl core functions.  This allows you to use the features of e.g.
[Log::Dispatch](https://metacpan.org/pod/Log::Dispatch) or [Log::Log4perl](https://metacpan.org/pod/Log::Log4perl) **without** having to make extensive
changes to your source code.

When loaded, it installs a \_\_WARN\_\_ and \_\_DIE\_\_ handler and intercepts any
output to STDERR.  It also takes over the messaging functions of [Carp](https://metacpan.org/pod/Carp).
Without being further activated, the standard Perl logging functions continue
to be executed: e.g. if you expect warnings to appear on STDERR, they will.

Then, when necessary, you can activate actual logging through e.g.
Log::Dispatch by installing a log dispatcher.  From then on, any warn, die,
carp, croak, cluck, confess or print to the STDERR handle,  will be logged
using the Log::Dispatch logging dispatcher.  Logging can be disabled and
enabled at any time for critical sections of code.

# LOG LEVELS

The following log levels are used:

## warning

Any `warn`, `Carp::carp` or `Carp::cluck` will generate a "warning" level
message.

## error

Any direct output to STDERR will generate an "error" level message.

## critical

Any `die`, `Carp::croak` or `Carp::confess` will generate a "critical"
level message.

# REQUIRED MODULES

    Scalar::Util (1.08)

# CAVEATS

The following caveats may apply to your situation.

## Associated modules

Although a module such as [Log::Dispatch](https://metacpan.org/pod/Log::Dispatch) is **not** listed as a prerequisite,
the real use of this module only comes into view when such a module **is**
installed.  Please note that for testing this module, you will need the
[Log::Dispatch::Buffer](https://metacpan.org/pod/Log::Dispatch::Buffer) module to also be available.

An alternate logger may be [Log::Log4perl](https://metacpan.org/pod/Log::Log4perl), although this has not been tested
by the author.  Any object that provides a `warning`, `error` and `critical`
method, will operate with this module.
Log4perl does not the message 'critical', so it will not work.
A wishlist request has been sent (RT121065).

## eval

In the current implementation of Perl, a \_\_DIE\_\_ handler is **also** called
inside an eval.  Whereas a normal `die` would just exit the eval, the \_\_DIE\_\_
handler \_will\_ get called inside the eval.  Which may or may not be what you
want.  To prevent the \_\_DIE\_\_ handler to be called inside eval's, add the
following line to the eval block or string being evaluated:

    local $SIG{__DIE__} = undef;

This disables the \_\_DIE\_\_ handler within the evalled block or string, and
will automatically enable it again upon exit of the evalled block or string.
Unfortunately there is no automatic way to do that for you.

# AUTHOR

Elizabeth Mattijsen, <liz@dijkmat.nl>.

Please report bugs to <perlbugs@dijkmat.nl>.

# COPYRIGHT

Copyright (c) 2004, 2007 Elizabeth Mattijsen <liz@dijkmat.nl>. All rights
reserved.  This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.
