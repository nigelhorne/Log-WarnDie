require 5.006;

use strict;
use ExtUtils::MakeMaker;
eval "use Devel::Required";

WriteMakefile (
 NAME		=> "Log::WarnDie",
 AUTHOR		=> 'Elizabeth Mattijsen (liz@dijkmat.nl)',
 ABSTRACT	=> 'Log::WarnDie - Log standard Perl warnings and errors on a log handler',
 VERSION_FROM	=> 'lib/Log/WarnDie.pm',

 PREREQ_PM	=> {qw(
                    Scalar::Util         1.08
                   )},
	BUILD_REQUIRES => {
		'Log::Dispatch::Null' => 0,
		'Test::Most' => 0,
	}
);
