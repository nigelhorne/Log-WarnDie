#!perl -w

use strict;
use warnings;

use Test::Most tests => 7;
use Test::Needs 'Net::SFTP::Foreign', 'Log::Disbatch::Buffer';
use Test::RequiresInternet ('test.rebex.net' => 'ssh');

# See https://rt.cpan.org/Public/Bug/Display.html?id=61932

BEGIN { use_ok('Log::WarnDie') }

my $dispatcher = new_ok('Log::Dispatch');

can_ok('Log::WarnDie', qw(dispatcher import unimport));

my $channel = Log::Dispatch::Buffer->new(qw(name default min_level debug));
isa_ok( $channel,'Log::Dispatch::Buffer' );

$dispatcher->add($channel);
is($dispatcher->output('default') ,$channel, 'Check if channel activated');

Log::WarnDie->dispatcher($dispatcher);

# http://www.sftp.net/public-online-sftp-servers
my $sftp = Net::SFTP::Foreign->new('demo@test.rebex.net', password => 'password');

ok(defined($sftp->ls('.')));
