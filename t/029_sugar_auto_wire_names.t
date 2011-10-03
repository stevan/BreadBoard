#!/usr/bin/perl

use strict;
use warnings;

use Test::More;

use Bread::Board;

{
    package FileLogger;
    use Moose;
    has 'log_file' => (is => 'ro', required => 1);

    package DBI;
    use Moose;

    has 'dsn'      => (is => 'ro', isa => 'Str');
    has 'username' => (is => 'ro', isa => 'Str');
    has 'password' => (is => 'ro', isa => 'Str');

    sub connect {
        my ($class, $dsn, $username, $password) = @_;
        $class->new(dsn => $dsn, username => $username, password => $password);
    }

    package MyApplication;
    use Moose;
    has 'logger' => (is => 'ro', isa => 'FileLogger', required => 1);
    has 'dbh'    => (is => 'ro', isa => 'DBI', required => 1);
}

my $c = container 'MyApp' => as {

    service 'log_file' => "logfile.log";

    service 'logger' => (
        class        => 'FileLogger',
        lifecycle    => 'Singleton',
        dependencies => ['log_file']
    );

    container 'Database' => as {
        service 'dsn'      => "dbi:sqlite:dbname=my-app.db";
        service 'username' => "user";
        service 'password' => "pass";

        service 'dbh' => (
            block => sub {
                my $s = shift;
                DBI->connect(
                    $s->param('dsn'),
                    $s->param('username'),
                    $s->param('password'),
                ) || die "Could not connect";
            },
            dependencies => [qw[dsn username password]]
        );
    };

    service 'application' => (
        class        => 'MyApplication',
        dependencies => ['logger', 'Database/dbh']
    );

};

my $logger = $c->resolve( service => 'logger' );
isa_ok($logger, 'FileLogger');

is($logger->log_file, 'logfile.log', '... got the right logfile dep');

is($c->fetch('logger/log_file')->service, $c->fetch('log_file'), '... got the right value');
is($c->fetch('logger/log_file')->get, 'logfile.log', '... got the right value');

my $dbh = $c->resolve( service => 'Database/dbh' );
isa_ok($dbh, 'DBI');

is($dbh->dsn, "dbi:sqlite:dbname=my-app.db", '... got the right dsn');
is($dbh->username, "user", '... got the right username');
is($dbh->password, "pass", '... got the right password');

my $app = $c->resolve( service => 'application');
isa_ok($app, 'MyApplication');

isa_ok($app->logger, 'FileLogger');
is($app->logger, $logger, '... got the right logger (singleton)');

isa_ok($app->dbh, 'DBI');
isnt($app->dbh, $dbh, '... got a different dbh');

done_testing;
