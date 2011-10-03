#!/usr/bin/perl

use strict;
use warnings;

use Test::More;
use Test::Moose;

BEGIN {
    use_ok('Bread::Board');
}

{
    package FileLogger;
    use Moose;
    has 'log_file' => (is => 'ro', required => 1);

    package DBH;
    use Moose;
    has 'dsn' => (is => 'ro', isa => 'Str');

    package MyApplication;
    use Moose;
    has 'logger' => (is => 'ro', isa => 'FileLogger', required => 1);
    has 'dbh'    => (is => 'ro', isa => 'DBH',        required => 1);
}

{
    package My::App;
    use Moose;
    use Bread::Board;

    extends 'Bread::Board::Container';

    has 'log_file_name' => (
        is      => 'ro',
        isa     => 'Str',
        default => 'logfile.log',
    );

    sub BUILD {
        my $self = shift;

        container $self => as {

            service 'log_file' => $self->log_file_name;

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

        };
    }

    package My::App::Extended;
    use Moose;
    use Bread::Board;

    extends 'My::App';

    has 'dsn' => (
        is       => 'ro',
        isa      => 'Str',
        required => 1,
    );

    sub BUILD {
        my $self = shift;
        container $self => as {

            service 'db_conn' => (
                class        => 'DBH',
                dependencies => [
                    (service 'dsn' => $self->dsn)
                ]
            );

            service 'application' => (
                class        => 'MyApplication',
                dependencies => {
                    logger => depends_on('logger'),
                    dbh    => depends_on('db_conn'),
                }
            );
        };
    }

}

my $c = My::App::Extended->new( name => 'MyApp', dsn => 'dbi:mysql:test' );
isa_ok($c, 'My::App::Extended');
isa_ok($c, 'My::App');
isa_ok($c, 'Bread::Board::Container');

# test the first one

my $logger = $c->resolve( service => 'logger' );
isa_ok($logger, 'FileLogger');

is($logger->log_file, 'logfile.log', '... got the right logfile dep');

is($c->fetch('logger/log_file')->service, $c->fetch('log_file'), '... got the right value');
is($c->fetch('logger/log_file')->get, 'logfile.log', '... got the right value');

my $dbh = $c->resolve( service => 'db_conn' );
isa_ok($dbh, 'DBH');

is($dbh->dsn, 'dbi:mysql:test', '... got the right dsn');

my $app = $c->resolve( service => 'application' );
isa_ok($app, 'MyApplication');

isa_ok($app->logger, 'FileLogger');
is($app->logger, $logger, '... got the right logger (singleton)');

isa_ok($app->dbh, 'DBH');
isnt($app->dbh, $dbh, '... got the right db_conn (not a singleton)');


done_testing;
