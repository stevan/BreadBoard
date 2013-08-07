#!/usr/bin/perl

use strict;
use warnings;

use Test::More;
use Test::Fatal;

use Bread::Board;

use Bread::Board::Types;

# roles
use Bread::Board::Service;
use Bread::Board::Service::WithClass;
use Bread::Board::Service::WithDependencies;
use Bread::Board::Service::WithParameters;

# services
use Bread::Board::ConstructorInjection;
use Bread::Board::SetterInjection;
use Bread::Board::BlockInjection;
use Bread::Board::Literal;

use Bread::Board::Container;
use Bread::Board::Dependency;

use Bread::Board::Traversable;

{
    package MyLogger;
    use Moose;

    package MyDBI;
    use Moose;

    has 'dsn'      => (is => 'ro', isa => 'Str');
    has 'username' => (is => 'ro', isa => 'Str');
    has 'password' => (is => 'ro', isa => 'Str');

    sub connect {
        my ($class, $dsn, $username, $password) = @_;
        $class->new(dsn => $dsn, username => $username, password => $password);
    }

    package MyAuthenticator;
    use Moose;
    has 'dbh'    => (is => 'ro', isa => 'MyDBI',        required => 1);
    has 'logger' => (is => 'ro', isa => 'MyLogger', required => 1);

}

my $c;
is(exception {
    $c = Bread::Board::Container->new( name => 'Application' );

    $c->add_service(
        Bread::Board::BlockInjection->new(
            name  => 'logger',
            block => sub { MyLogger->new() }
        )
    );

    $c->add_service(
        Bread::Board::BlockInjection->new(
            name  => 'db_conn',
            block => sub { MyDBI->connect('dbi:mysql:test', '', '') }
        )
    );

    $c->add_service(
        Bread::Board::BlockInjection->new(
            name  => 'authenticator',
            block => sub {
                  my $service = shift;
                  MyAuthenticator->new(
                      dbh    => $service->param('db_conn'),
                      logger => $service->param('logger')
                  );
            },
            dependencies => {
                db_conn => Bread::Board::Dependency->new(service_path => 'db_conn'),
                logger  => Bread::Board::Dependency->new(service_path => 'logger'),
            }
        )
    );

}, undef, '... container compiled successfully');

my $authenticator;
is(exception {
    $authenticator = $c->resolve( service => 'authenticator' )
}, undef, '... and the container compiled correctly');


isa_ok($authenticator, 'MyAuthenticator');
isa_ok($authenticator->dbh, 'MyDBI');
isa_ok($authenticator->logger, 'MyLogger');


done_testing;
