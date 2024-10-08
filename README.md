[![Linux Build Status](https://travis-ci.org/nigelhorne/Log-WarnDie.svg?branch=master)](https://travis-ci.org/nigelhorne/Log-WarnDie)
[![Windows Build status](https://ci.appveyor.com/api/projects/status/1t1yhvagx00c2qi8?svg=true)](https://ci.appveyor.com/project/nigelhorne/cgi-info)
[![Dependency Status](https://dependencyci.com/github/nigelhorne/Log-WarnDie/badge)](https://dependencyci.com/github/nigelhorne/Log-WarnDie)
[![Coverage Status](https://coveralls.io/repos/github/nigelhorne/Log-WarnDie/badge.svg?branch=master)](https://coveralls.io/github/nigelhorne/Log-WarnDie?branch=master)
[![CPAN](https://img.shields.io/cpan/v/Log-WarnDie.svg)](http://search.cpan.org/~nhorne/Log-WarnDie/)

# NAME

Log::WarnDie - Log standard Perl warnings and errors on a log handler

# VERSION

Version 0.11

# SYNOPSIS

    use Log::WarnDie; # install to be used later
    use Log::Dispatch;
    use Log::Dispatch::Email::Sendmail;

    my $dispatcher = Log::Dispatch->new();       # can be any dispatcher!
    $dispatcher->add( Log::Dispatch::Email::Sendmail->new( # whatever output you like
     name      => 'foo',
     min_level => 'info',
    ) );

    use Log::WarnDie $dispatcher; # activate later

    Log::WarnDie->dispatcher( $dispatcher ); # same

    warn "This is a warning";       # now also dispatched
    die "Sorry it didn't work out"; # now also dispatched

    no Log::WarnDie; # deactivate later

    Log::WarnDie->dispatcher( undef ); # same

    Log::WarnDie->filter(\&filter);
    warn "This is a warning"; # no longer dispatched
    die "Sorry it didn't work out"; # no longer dispatched

    # Filter out File::stat noise
    sub filter {
            return ($_[0] !~ /^S_IFFIFO is not a valid Fcntl macro/);
    }

# DESCRIPTION

The "Log::WarnDie" module offers a logging alternative for standard
Perl core functions.  This allows you to use the features of e.g.
[Log::Dispatch](https://metacpan.org/pod/Log%3A%3ADispatch), [Log::Any](https://metacpan.org/pod/Log%3A%3AAny) or [Log::Log4perl](https://metacpan.org/pod/Log%3A%3ALog4perl) **without** having to make extensive
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

The following log levels are used:

## warning

Any `warn`, `Carp::carp` or `Carp::cluck` will generate a "warning" level
message.

## error

Any direct output to STDERR will generate an "error" level message.

## critical

Any `die`, `Carp::croak` or `Carp::confess` will generate a "critical"
level message.

# SUBROUTINES/METHODS

## dispatcher

Class method to set and/or return the current dispatcher

\# IN: 1 class (ignored)
\#     2 new dispatcher (optional)
\# OUT: 1 current dispatcher

## filter

Class method to set and/or get the current output filter

The given callback function should return 1 to output the given message, or 0
to drop it.
Useful for noisy messages such as File::stat giving S\_IFFIFO is not a valid Fcntl macro.

# AUTHOR

Elizabeth Mattijsen, <liz@dijkmat.nl>

Maintained by Nigel Horne, `<njh at bandsman.co.uk>`

# BUGS

Please report any bugs or feature requests to `bug-log-warndie at rt.cpan.org`,
or through the web interface at
[http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Log-WarnDie](http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Log-WarnDie).
I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

# CAVEATS

The following caveats may apply to your situation.

## Associated modules

Although a module such as [Log::Dispatch](https://metacpan.org/pod/Log%3A%3ADispatch) is **not** listed as a prerequisite,
the real use of this module only comes into view when such a module **is**
installed.  Please note that for testing this module, you will need the
[Log::Dispatch::Buffer](https://metacpan.org/pod/Log%3A%3ADispatch%3A%3ABuffer) module to also be available.

This module has been tested with
[Log::Dispatch](https://metacpan.org/pod/Log%3A%3ADispatch), [Log::Any](https://metacpan.org/pod/Log%3A%3AAny) and [Log::Log4perl](https://metacpan.org/pod/Log%3A%3ALog4perl).
In principle any object which recognises `warning`, `error` and `critical` should work.

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

# COPYRIGHT

Copyright (c) 2004, 2007 Elizabeth Mattijsen <liz@dijkmat.nl>. All rights
reserved.  This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

Portions of versions 0.06 onwards, Copyright 2017-2024 Nigel Horne
