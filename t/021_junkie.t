#!/usr/bin/perl

use strict;
use warnings;

use Test::More no_plan => 1;

BEGIN {
    use_ok('Junkie');     
}

{
    package FileLogger;
    use Moose;
    has 'log_file' => (is => 'ro', required => 1);
    
    package MyApplication;
    use Moose;
    has 'logger' => (is => 'ro', isa => 'FileLogger', required => 1);
}

sub loggers {
    service 'log_file' => "logfile.log";
    
    service 'logger' => (
        class        => 'FileLogger',
        lifecycle    => 'Singleton',
        dependencies => {
            log_file => depends_on('log_file'),
        }
    );    
}

my $c = container 'MyApp' => as {
    
    loggers(); # reuse baby !!!
    
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







