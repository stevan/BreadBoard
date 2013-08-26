#!/usr/bin/perl

use strict;
use warnings;

use Test::More;
use Test::Moose;

use Bread::Board;

{
    package FileLogger;
    use Moose;
    has 'log_file' => (is => 'ro', required => 1);

    package MyApplication;
    use Moose;
    has 'logger' => (is => 'ro', isa => 'FileLogger', required => 1);
}


my $file_service = service 'log_file' => "logfile.log";

ok($file_service->does('Bread::Board::Service'), '... this does Bread::Board::Service');

my $logger_service = service 'logger' => (
    class        => 'FileLogger',
    lifecycle    => 'Singleton',
    dependencies => {
        log_file => depends_on('log_file'),
    }
);

ok($logger_service->does('Bread::Board::Service'), '... this does Bread::Board::Service');

my $app_service = service 'application' => (
    class        => 'MyApplication',
    dependencies => {
        logger => depends_on('logger'),
    }
);

ok($app_service->does('Bread::Board::Service'), '... this does Bread::Board::Service');

my $bunyan_service = alias 'paul_bunyan' => 'logger';

ok($bunyan_service->does('Bread::Board::Service'), '... this does Bread::Board::Service');;
isa_ok($bunyan_service, 'Bread::Board::Service::Alias');

my $c = container 'MyApp';

isa_ok($c, 'Bread::Board::Container');

foreach ( $file_service, $logger_service, $app_service, $bunyan_service) {
    $c->add_service($_);
}

my $logger = $c->resolve( service => 'logger' );
isa_ok($logger, 'FileLogger');

is($logger->log_file, 'logfile.log', '... got the right logfile dep');

is($c->fetch('logger/log_file')->service, $c->fetch('log_file'), '... got the right value');
is($c->fetch('logger/log_file')->get, 'logfile.log', '... got the right value');

my $app = $c->resolve( service => 'application' );
isa_ok($app, 'MyApplication');

isa_ok($app->logger, 'FileLogger');
is($app->logger, $logger, '... got the right logger (singleton)');

my $bunyan = $c->resolve( service => 'paul_bunyan' );
isa_ok($bunyan, 'FileLogger');
is($bunyan, $logger, 'standalone alias works.');

done_testing;
