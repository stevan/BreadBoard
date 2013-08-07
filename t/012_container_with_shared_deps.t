#!/usr/bin/perl

use strict;
use warnings;

use Test::More;
use Test::Moose;

use Bread::Board::Container;
use Bread::Board::ConstructorInjection;
use Bread::Board::BlockInjection;
use Bread::Board::Literal;
use Bread::Board::Dependency;

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
                dsn  => Bread::Board::Dependency->new(service => Bread::Board::Literal->new(name => 'dsn',  value => '')),
                user => Bread::Board::Dependency->new(service => Bread::Board::Literal->new(name => 'user', value => '')),
                pass => Bread::Board::Dependency->new(service => Bread::Board::Literal->new(name => 'pass', value => '')),
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
ok($s->does('Bread::Board::Service'), '... this does the Service role');

my $dbh = $s->get;
isa_ok($dbh, 'DBH');

done_testing;
