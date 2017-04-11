require 5.006;

use strict;
use ExtUtils::MakeMaker;
eval "use Devel::Required";

WriteMakefile (
	NAME		=> "Log::WarnDie",
	# AUTHOR		=> 'Elizabeth Mattijsen (liz@dijkmat.nl)',
	AUTHOR		=> q{Nigel Horne <njh@bandsman.co.uk>},
	VERSION_FROM	=> 'lib/Log/WarnDie.pm',
	ABSTRACT_FROM   => 'lib/Log/WarnDie.pm',
	((defined($ExtUtils::MakeMaker::VERSION) &&
		($ExtUtils::MakeMaker::VERSION >= 6.3002))
		? ('LICENSE'=> 'GPL')
		: ()),
	PREREQ_PM	=> {
		'Scalar::Util' => 1.08,
	},
	BUILD_REQUIRES => {
		'Log::Dispatch::Null' => 0,
		'Test::Most' => 0,
	},
	dist		=> { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
	clean		=> { FILES => 'Log::WarnDie-*' },
	META_MERGE	=> {
		'meta-spec' => { version => 2 },
		resources => {
			repository => {
				type => 'git',
				url => 'git://github.com/nigelhorne/Log::WarnDie.git',
				web => 'https://github.com/nigelhorne/Log::WarnDie',
			},
			bugtracker => {
				web => 'https://rt.cpan.org/Public/Dist/Display.html?Name=Log::WarnDie',
				mailto => 'bug-Log::WarnDie@rt.cpan.org'
			}
		}
	},
	MIN_PERL_VERSION	=> '5.6.2'
);
