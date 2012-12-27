#!/usr/bin/perl

use strict;
use warnings;

use Test::More;
use Scalar::Util qw(refaddr);

use Bread::Board;

{
    package Test::Class;
    use Moose;
    has 'dep' => ( is => 'ro', isa => 'Int' );
}

my $board = Bread::Board::Container->new( name => 'app' );
isa_ok($board, 'Bread::Board::Container');

$board->add_service(
    Bread::Board::ConstructorInjection->new(
        lifecycle => 'Singleton',
        name      => 'test',
        class     => 'Test::Class',
        dependencies => {
            dep => Bread::Board::Dependency->new(service_path => '/dep'),
        },
    )
);
ok($board->has_service('test'), '... got the test service');
isa_ok($board->get_service('test'), 'Bread::Board::ConstructorInjection');

$board->add_service(
    Bread::Board::Literal->new(name => 'dep', value => 1)
);
ok($board->has_service('dep'), '... got the dep service');
isa_ok($board->get_service('dep'), 'Bread::Board::Literal');

## check the singleton-ness

is($board->fetch('/test')->get, $board->fetch('/test')->get, '... got the singleton');

# clone ...

my $board2 = $board->clone;
isa_ok($board2, 'Bread::Board::Container');
isnt($board, $board2, '... they are not the same instance');

ok($board2->has_service('test'), '... got the test service');
isa_ok($board2->get_service('test'), 'Bread::Board::ConstructorInjection');

ok($board2->has_service('dep'), '... got the dep service');
isa_ok($board2->get_service('dep'), 'Bread::Board::Literal');

isnt($board->get_service('test'), $board2->get_service('test'), '... not the same test services');
isnt($board->get_service('dep'), $board2->get_service('dep'), '... not the same dep services');

## check the singleton-ness

is($board2->fetch('/test')->get, $board2->fetch('/test')->get, '... got the singleton');

## check the singleton-less-ness

isnt($board->fetch('/test')->get, $board2->fetch('/test')->get, '... singleton are not shared');

done_testing;
