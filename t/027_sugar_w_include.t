#!/usr/bin/perl

use strict;
use warnings;
use FindBin;

use Test::More tests => 10;
use Test::Exception;

BEGIN {
    use_ok('Bread::Board');
}


throws_ok { local $SIG{__WARN__} = sub { }; include "$FindBin::Bin/lib/bad.bb" }
          qr/Couldn't compile.*bad\.bb.*syntax error.*function_doesnt_exist/,
          "we get appropriate errors for invalid files";

throws_ok { include "$FindBin::Bin/lib/doesnt_exist.bb" }
          qr/Couldn't open.*doesnt_exist\.bb.*for reading/,
          "we get appropriate errors for files that don't exist";

{
    package FileLogger;
    use Moose;
    has 'log_file' => (is => 'ro', required => 1);

    package MyApplication;
    use Moose;
    has 'logger' => (is => 'ro', isa => 'FileLogger', required => 1);
}

my $c = container 'MyApp' => as {

    service 'log_file' => "logfile.log";

    include "$FindBin::Bin/lib/logger.bb";

    service 'application' => (
        class        => 'MyApplication',
        dependencies => {
            logger => depends_on('logger'),
        }
    );
};

my $logger = $c->fetch('logger')->get;
isa_ok($logger, 'FileLogger');

is($logger->log_file, 'logfile.log', '... got the right logfile dep');

is($c->fetch('logger/log_file')->service, $c->fetch('log_file'), '... got the right value');
is($c->fetch('logger/log_file')->get, 'logfile.log', '... got the right value');

my $app = $c->fetch('application')->get;
isa_ok($app, 'MyApplication');

isa_ok($app->logger, 'FileLogger');
is($app->logger, $logger, '... got the right logger (singleton)');







