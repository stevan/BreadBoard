#!/usr/bin/perl

use strict;
use warnings;

use Test::More;
use Test::Exception;
use Test::Moose;

BEGIN {
    use_ok('Bread::Board');
}

{
    package FileLogger;
    use Moose;
    has 'log_file' => (is => 'ro', required => 1);

    package MyApplication;
    use Moose;
    has 'logger' => (is => 'ro', isa => 'FileLogger', required => 1);
}

{
    package My::App;
    use Moose;
    use Bread::Board;

    extends 'Bread::Board::Container';

    sub BUILD {
        my $self = shift;

        local $Bread::Board::CC = $self;

        service 'log_file' => "logfile.log";

        service 'logger' => (
            class        => 'FileLogger',
            lifecycle    => 'Singleton',
            dependencies => {
                log_file => depends_on('log_file'),
            }
        );

        service 'application' => (
            class        => 'MyApplication',
            dependencies => {
                logger => depends_on('logger'),
            }
        );
    }
}

my $c1 = My::App->new( name => 'MyApp1' );
isa_ok($c1, 'My::App');
isa_ok($c1, 'Bread::Board::Container');

my $c2 = My::App->new( name => 'MyApp2' );
isa_ok($c2, 'My::App');
isa_ok($c2, 'Bread::Board::Container');

# test the first one

my $logger1 = $c1->fetch('logger')->get;
isa_ok($logger1, 'FileLogger');

is($logger1->log_file, 'logfile.log', '... got the right logfile dep');

is($c1->fetch('logger/log_file')->service, $c1->fetch('log_file'), '... got the right value');
is($c1->fetch('logger/log_file')->get, 'logfile.log', '... got the right value');

my $app1 = $c1->fetch('application')->get;
isa_ok($app1, 'MyApplication');

isa_ok($app1->logger, 'FileLogger');
is($app1->logger, $logger1, '... got the right logger (singleton)');

# test the second one

my $logger2 = $c2->fetch('logger')->get;
isa_ok($logger2, 'FileLogger');

is($logger2->log_file, 'logfile.log', '... got the right logfile dep');

is($c2->fetch('logger/log_file')->service, $c2->fetch('log_file'), '... got the right value');
is($c2->fetch('logger/log_file')->get, 'logfile.log', '... got the right value');

my $app2 = $c2->fetch('application')->get;
isa_ok($app2, 'MyApplication');

isa_ok($app2->logger, 'FileLogger');
is($app2->logger, $logger2, '... got the right logger (singleton)');

# make sure they share nothing

isnt( $logger1, $logger2, '... these are not the same' );
isnt( $app1, $app2, '... these are not the same' );

done_testing;