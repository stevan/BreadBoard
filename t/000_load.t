#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 16;
use Test::Exception;

BEGIN {
    use_ok('Bread::Board');

    use_ok('Bread::Board::Types');

    # roles
    use_ok('Bread::Board::Service');
    use_ok('Bread::Board::Service::WithClass');
    use_ok('Bread::Board::Service::WithDependencies');
    use_ok('Bread::Board::Service::WithParameters');

    # services
    use_ok('Bread::Board::ConstructorInjection');
    use_ok('Bread::Board::SetterInjection');
    use_ok('Bread::Board::BlockInjection');
    use_ok('Bread::Board::Literal');

    use_ok('Bread::Board::Container');
    use_ok('Bread::Board::Dependency');

    use_ok('Bread::Board::Traversable');

    use_ok('Bread::Board::LifeCycle::Singleton');
}

{
    package MyFileLogger;
    use Moose;
    has 'log_file_name' => (is => 'ro', required => 1);

    package MyDBI;
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
    has 'dbh'    => (is => 'ro', isa => 'MyDBI',        required => 1);
    has 'logger' => (is => 'ro', isa => 'MyFileLogger', required => 1);

    sub run { 1 }
}

my $c;
lives_ok {
    $c = container 'MyApp' => as {

        service 'log_file_name' => "logfile.log";

        service 'logger' => (
            class        => 'MyFileLogger',
            lifecycle    => 'Singleton',
            dependencies => [
                depends_on('log_file_name'),
            ]
        );

        container 'Database' => as {
            service 'dsn'      => "dbi:sqlite:dbname=my-app.db";
            service 'username' => "user234";
            service 'password' => "****";

            service 'dbh' => (
                block => sub {
                    my $s = shift;
                    MyDBI->connect(
                        $s->param('dsn'),
                        $s->param('username'),
                        $s->param('password'),
                    ) || die "Could not connect";
                },
                dependencies => wire_names(qw[dsn username password])
            );
        };

        service 'application' => (
            class        => 'MyApplication',
            dependencies => {
                logger => depends_on('logger'),
                dbh    => depends_on('Database/dbh'),
            }
        );

    };
} '... container compiled successfully';


ok($c->fetch('application')->get->run, '... the applicaton ran');

