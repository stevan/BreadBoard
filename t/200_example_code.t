#!/usr/bin/perl

use strict;
use warnings;

use Test::More;
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
lives_ok {
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

} '... container compiled successfully';

my $authenticator;
lives_ok {
    $authenticator = $c->resolve( service => 'authenticator' )
} '... and the container compiled correctly';


isa_ok($authenticator, 'MyAuthenticator');
isa_ok($authenticator->dbh, 'MyDBI');
isa_ok($authenticator->logger, 'MyLogger');


done_testing;



