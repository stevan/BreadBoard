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
    package Logger::Role;
    use Moose::Role;

    requires 'log';

    package My::Logger;
    use Moose;

    with 'Logger::Role';

    sub log {}

    package My::DBI;
    use Moose;

    has 'dsn' => (is => 'ro', isa => 'Str');

    sub connect {
        my ($class, $dsn) = @_;
        $class->new( dsn => $dsn );
    }

    package My::Application;
    use Moose;

    has 'logger' => (is => 'ro', does => 'Logger::Role', required => 1);
    has 'dbh'    => (is => 'ro', isa  => 'My::DBI',      required => 1);
}

my $c = container 'Automat' => as {

    service 'dsn'    => 'dbi:sqlite:test';
    service 'dbh'    => (
        block => sub {
            my $s = shift;
            My::DBI->connect( $s->param( 'dsn' ) );
        },
        dependencies => [ depends_on('dsn') ]
    );

    # map a type to a service implementation ...
    typemap 'My::DBI' => 'dbh';

    # ask the container to infer a service,
    # but give it some hints ....
    typemap 'Logger::Role' => infer( class => 'My::Logger' );

    # ask the container to infer the
    # entire service ...
    typemap 'My::Application' => infer;
};

my $app = $c->resolve( type => 'My::Application' );
isa_ok($app, 'My::Application');
isa_ok($app->logger, 'My::Logger');
isa_ok($app->dbh, 'My::DBI');
is($app->dbh->dsn, 'dbi:sqlite:test', '... got the right DSN too');


done_testing;