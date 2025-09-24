#!/usr/bin/env perl

require 5.006;
use strict;
use warnings;

use ExtUtils::MakeMaker 6.64;	# 6.64 for TEST_REQUIRES
eval 'use Devel::Required';

my $dist = {
	COMPRESS => 'gzip -9f',
	SUFFIX => 'gz'
};

if($^O eq 'darwin') {
	$dist->{'TAR'} = 'gtar';
}

WriteMakefile (
	NAME		=> "Log::WarnDie",
	# AUTHOR		=> 'Elizabeth Mattijsen (liz@dijkmat.nl)',
	AUTHOR		=> q{Nigel Horne <njh@nigelhorne.com>},
	VERSION_FROM	=> 'lib/Log/WarnDie.pm',
	ABSTRACT_FROM => 'lib/Log/WarnDie.pm',
	((defined($ExtUtils::MakeMaker::VERSION) &&
		($ExtUtils::MakeMaker::VERSION >= 6.3002))
		? ('LICENSE'=> 'GPL')
		: ()),
	CONFIGURE_REQUIRES => {
		'ExtUtils::MakeMaker' => 6.64	# Minimum version for TEST_REQUIRES
	}, PREREQ_PM	=> {
		'Scalar::Util' => 1.08,
	}, TEST_REQUIRES => {
		'autodie' => 0,
		'Log::Dispatch::Null' => 0,
		'Test::DescribeMe' => 0,
		'Test::Most' => 0,
		'Test::Needs' => 0,
		'Test::TempDir::Tiny' => 0,
		'IPC::System::Simple' => 0,
		'Test::File::Contents' => 0,
		'Test::RequiresInternet' => 0,
		'File::Slurp' => 0,
		'File::Spec' => 3.4
	}, dist => $dist,
	clean		=> { FILES => 'Log-WarnDie-*' },
	META_MERGE	=> {
		'meta-spec' => { version => 2 },
		resources => {
			repository => {
				type => 'git',
				url => 'git://github.com/nigelhorne/Log::WarnDie.git',
				web => 'https://github.com/nigelhorne/Log::WarnDie',
				repository => 'https://github.com/nigelhorne/Log-WarnDie',
			},
			bugtracker => {
				web => 'https://rt.cpan.org/Public/Dist/Display.html?Name=Log::WarnDie',
				url => 'https://rt.cpan.org/Public/Dist/Display.html?Name=Log::WarnDie',
				# web => 'https://github.com/nigelhorne/Log-WarnDie',
				mailto => 'bug-Log::WarnDie@rt.cpan.org'
			}
		}
	},
	MIN_PERL_VERSION	=> '5.6.2'
);
