#!/usr/bin/perl

use strict;
use warnings;

use Test::More no_plan => 1;
use Test::Moose;
use Test::Exception;

BEGIN {
    use_ok('Junkie::Container');
    use_ok('Junkie::ConstructorInjection');
    use_ok('Junkie::BlockInjection');    
    use_ok('Junkie::Literal');
}

{
    package DBH;
    use Moose;
    has ['dsn', 'user', 'pass'] => (required => 1);
}

my $c = Junkie::Container->new(
    name     => 'Model',
    services => [
        Junkie::ConstructorInjection->new(
            name  => 'schema',
            class => 'My::App::Schema',
            dependencies => {
                dsn  => Junkie::Literal->new(name => 'dsn',  value => ''),
                user => Junkie::Literal->new(name => 'user', value => ''),
                pass => Junkie::Literal->new(name => 'pass', value => ''),
            },
        ),
        Junkie::BlockInjection->new(
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
                dsn  => Junkie::Dependency->new(service_path => '../../schema/dsn'),
                user => Junkie::Dependency->new(service_path => '../../schema/user'),
                pass => Junkie::Dependency->new(service_path => '../../schema/pass'),
            },            
        )
    ]
);

my $s = $c->fetch('dbh');
does_ok($s, 'Junkie::Service');

my $dbh = $s->get;
isa_ok($dbh, 'DBH');







