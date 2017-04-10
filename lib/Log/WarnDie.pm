package Log::WarnDie;

# Make sure we have version info for this module
# Be strict from now on

$VERSION = '0.05';
use strict;

# Make sure we have the modules that we need

use IO::Handle ();
use Scalar::Util qw(blessed);

# The logging dispatcher that should be used
# The (original) error output handle
# Reference to the previous parameters sent

my $DISPATCHER;
my $STDERR;
my $LAST;

# Old settings of standard Perl logging mechanisms

my $WARN;
my $DIE;

#---------------------------------------------------------------------------

# Tie subroutines need to be known at compile time, hence there here, near
# the start of code rather than near the end where these would normally live.

#---------------------------------------------------------------------------
# TIEHANDLE
#
# Called whenever a dispatcher is activated
#
#  IN: 1 class with which to bless
# OUT: 1 blessed object 

sub TIEHANDLE { bless \"$_[0]",$_[0] } #TIEHANDLE

#---------------------------------------------------------------------------
# PRINT
#
# Called whenever something is printed on STDERR
#
#  IN: 1 blessed object returned by TIEHANDLE
#      2..N whatever was needed to be printed

sub PRINT {

# Lose the object
# If there is a dispatcher
#  Put it in the log handler if not the same as last time
#  Reset the flag
# Make sure it appears on the original STDERR as well

    shift;
    if ($DISPATCHER) {
        $DISPATCHER->error( @_ )
         unless $LAST and @$LAST == @_ and join( '',@$LAST ) eq join( '',@_ );
        undef $LAST;
    }
    print $STDERR @_;
} #PRINT

#---------------------------------------------------------------------------
# PRINTF
#
# Called whenever something is printed on STDERR
#
#  IN: 1 blessed object returned by TIEHANDLE
#      2..N whatever was needed to be printed

sub PRINTF {

# Lose the object
# If there is a dispatcher
#  Put it in the log handler if not the same as last time
#  Reset the flag
# Make sure it appears on the original STDERR as well

    shift;
    if ($DISPATCHER) {
        $DISPATCHER->error( @_ )
         unless $LAST and @$LAST == @_ and join( '',@$LAST ) eq join( '',@_ );
        undef $LAST;
    }
    printf $STDERR @_;
} #PRINT

#---------------------------------------------------------------------------
# At compile time
#  Create new handle
#  Make sure it's the same as the current STDERR
#  Make sure the original STDERR is now handled by our sub

BEGIN {
    $STDERR = new IO::Handle;
    $STDERR->fdopen( fileno( STDERR ),"w" )
     or die "Could not open STDERR 2nd time: $!\n";
    tie *STDERR,__PACKAGE__;

#  Save current __WARN__ setting
#  Replace it with a sub that
#   If there is a dispatcher
#    Remembers the last parameters
#    Dispatches a warning message
#   Executes the standard system warn() or whatever was there before

    $WARN = $SIG{__WARN__};
    $SIG{__WARN__} = sub {
        if ($DISPATCHER) {
            $LAST = \@_;
            $DISPATCHER->warning( @_ );
        }
        $WARN ? $WARN->( @_ ) : CORE::warn( @_ );
    };

#  Save current __DIE__ setting
#  Replace it with a sub that
#   If there is a dispatcher
#    Remembers the last parameters
#    Dispatches a critical message
#   Executes the standard system die() or whatever was there before

    $DIE = $SIG{__DIE__};
    $SIG{__DIE__} = sub {
        if ($DISPATCHER) {
            $LAST = \@_;
            $DISPATCHER->critical( @_ );
        }
        $DIE ? $DIE->( @_ ) : CORE::die( @_ );
    };

#  Make sure we won't be listed ourselves by Carp::

    $Carp::Internal{__PACKAGE__} = 1;
} #BEGIN

# Satisfy require

1;

#---------------------------------------------------------------------------

# Class methods

#---------------------------------------------------------------------------
# dispatcher
#
# Set and/or return the current dispatcher
#
#  IN: 1 class (ignored)
#      2 new dispatcher (optional)
# OUT: 1 current dispatcher

sub dispatcher {

# Return the current dispatcher if no changes needed
# Set the new dispatcher

    return $DISPATCHER unless @_ > 1;
    $DISPATCHER = $_[1];

# If there is a dispatcher now
#  If the dispatcher is a Log::Dispatch er
#   Make sure all of standard Log::Dispatch stuff becomes invisible for Carp::
#   If there are outputs already
#    Make sure all of the output objects become invisible for Carp::

    if ($DISPATCHER) {
        if ($DISPATCHER->isa( 'Log::Dispatch' )) {
            $Carp::Internal{$_} = 1
             foreach 'Log::Dispatch','Log::Dispatch::Output';
            if (my $outputs = $DISPATCHER->{'outputs'}) {
                $Carp::Internal{$_} = 1
                 foreach map {blessed $_} values %{$outputs};
            }
        }
    }

# Return the current dispatcher

    $DISPATCHER;
} #dispatcher

#---------------------------------------------------------------------------

# Perl standard features

#---------------------------------------------------------------------------
# import
#
# Called whenever a -use- is done.
#
#  IN: 1 class (ignored)
#      2 new dispatcher (optional)

*import = \&dispatcher;

#---------------------------------------------------------------------------
# unimport
#
# Called whenever a -use- is done.
#
#  IN: 1 class (ignored)

sub unimport { import( undef ) } #unimport

#---------------------------------------------------------------------------

__END__

=head1 NAME

Log::WarnDie - Log standard Perl warnings and errors on a log handler

=head1 SYNOPSIS

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

=head1 VERSION

This documentation describes version 0.05.

=head1 DESCRIPTION

The "Log::WarnDie" module offers a logging alternative for standard
Perl core functions.  This allows you to use the features of e.g.
L<Log::Dispatch> or L<Log::Log4perl> B<without> having to make extensive
changes to your source code.

When loaded, it installs a __WARN__ and __DIE__ handler and intercepts any
output to STDERR.  It also takes over the messaging functions of L<Carp>.
Without being further activated, the standard Perl logging functions continue
to be executed: e.g. if you expect warnings to appear on STDERR, they will.

Then, when necessary, you can activate actual logging through e.g.
Log::Dispatch by installing a log dispatcher.  From then on, any warn, die,
carp, croak, cluck, confess or print to the STDERR handle,  will be logged
using the Log::Dispatch logging dispatcher.  Logging can be disabled and
enabled at any time for critical sections of code.

=head1 LOG LEVELS

The following log levels are used:

=head2 warning

Any C<warn>, C<Carp::carp> or C<Carp::cluck> will generate a "warning" level
message.

=head2 error

Any direct output to STDERR will generate an "error" level message.

=head2 critical

Any C<die>, C<Carp::croak> or C<Carp::confess> will generate a "critical"
level message.

=head1 REQUIRED MODULES

 Scalar::Util (1.08)

=head1 CAVEATS

The following caveats may apply to your situation.

=head2 Associated modules

Although a module such as L<Log::Dispatch> is B<not> listed as a prerequisite,
the real use of this module only comes into view when such a module B<is>
installed.  Please note that for testing this module, you will need the
L<Log::Dispatch::Buffer> module to also be available.

An alternate logger may be L<Log::Log4perl>, although this has not been tested
by the author.  Any object that provides a C<warning>, C<error> and C<critical>
method, will operate with this module.
Log4perl does not the message 'critical', so it will not work.
A wishlist request has been sent (RT121065).

=head2 eval

In the current implementation of Perl, a __DIE__ handler is B<also> called
inside an eval.  Whereas a normal C<die> would just exit the eval, the __DIE__
handler _will_ get called inside the eval.  Which may or may not be what you
want.  To prevent the __DIE__ handler to be called inside eval's, add the
following line to the eval block or string being evaluated:

  local $SIG{__DIE__} = undef;

This disables the __DIE__ handler within the evalled block or string, and
will automatically enable it again upon exit of the evalled block or string.
Unfortunately there is no automatic way to do that for you.

=head1 AUTHOR

Elizabeth Mattijsen, <liz@dijkmat.nl>.

Please report bugs to <perlbugs@dijkmat.nl>.

=head1 COPYRIGHT

Copyright (c) 2004, 2007 Elizabeth Mattijsen <liz@dijkmat.nl>. All rights
reserved.  This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
