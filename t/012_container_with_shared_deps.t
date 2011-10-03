#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 6;
use Test::Moose;

BEGIN {
    use_ok('Bread::Board::Container');
    use_ok('Bread::Board::ConstructorInjection');
    use_ok('Bread::Board::BlockInjection');
    use_ok('Bread::Board::Literal');
}

{
    package DBH;
    use Moose;
    has ['dsn', 'user', 'pass'] => (is => 'ro', required => 1);
}

my $c = Bread::Board::Container->new(
    name     => 'Model',
    services => [
        Bread::Board::ConstructorInjection->new(
            name  => 'schema',
            class => 'My::App::Schema',
            dependencies => {
                dsn  => Bread::Board::Literal->new(name => 'dsn',  value => ''),
                user => Bread::Board::Literal->new(name => 'user', value => ''),
                pass => Bread::Board::Literal->new(name => 'pass', value => ''),
            },
        ),
        Bread::Board::BlockInjection->new(
            name => 'dbh',
            block => sub {
                my $s = shift;
                DBH->new(
                    dsn  => $s->param('dsn'),
                    user => $s->param('user'),
                    pass => $s->param('pass'),
                )
            },
            dependencies => {
                dsn  => Bread::Board::Dependency->new(service_path => 'schema/dsn'),
                user => Bread::Board::Dependency->new(service_path => 'schema/user'),
                pass => Bread::Board::Dependency->new(service_path => 'schema/pass'),
            },
        )
    ]
);

my $s = $c->fetch('dbh');
does_ok($s, 'Bread::Board::Service');

my $dbh = $s->get;
isa_ok($dbh, 'DBH');







