#!/usr/bin/perl

use strict;
use warnings;

use Test::More;
use Scalar::Util qw(refaddr);

use Bread::Board;

{
    package Test::Class;
    use Moose;
    has 'dep' => ( is => 'rw', isa => 'Int' );
}

my $board = Bread::Board::Container->new( name => 'app' );
isa_ok($board, 'Bread::Board::Container');

$board->add_service(
    Bread::Board::SetterInjection->new(
        name  => 'test',
        class => 'Test::Class',
        dependencies => {
            dep => Bread::Board::Dependency->new(service_path => '/app/dep'),
        },
    )
);
ok($board->has_service('test'), '... got the test service');
isa_ok($board->get_service('test'), 'Bread::Board::SetterInjection');

# clone ...

my $board2 = $board->clone;
isa_ok($board2, 'Bread::Board::Container');
isnt($board, $board2, '... they are not the same instance');

ok($board2->has_service('test'), '... got the test service');
isa_ok($board2->get_service('test'), 'Bread::Board::SetterInjection');

isnt($board->get_service('test'), $board2->get_service('test'), '... not the same test services');

# add dep services ...

$board->add_service(
    Bread::Board::Literal->new(name => 'dep', value => 1)
);
ok($board->has_service('dep'), '... got the dep service');
isa_ok($board->get_service('dep'), 'Bread::Board::Literal');

ok(!$board2->has_service('dep'), '... board2 does not have the dep service');

$board2->add_service(
    Bread::Board::Literal->new(name => 'dep', value => 2)
);
ok($board2->has_service('dep'), '... got the dep service');
isa_ok($board2->get_service('dep'), 'Bread::Board::Literal');

isnt($board->get_service('dep'), $board2->get_service('dep'), '... not the same dep services');

# test them ...

is($board->fetch('/app/dep')->get(), 1, '... got correct dep');
is($board->fetch('/app/test')->get()->dep, 1, '... test uses dep');
is(refaddr $board->fetch('/app/test')->parent, refaddr $board, '... got the right board');

is($board2->fetch('/app/dep')->get(), 2, '... got correct dep');
is($board2->fetch('/app/test')->get()->dep, 2, '... test uses dep');
is(refaddr $board2->fetch('/app/test')->parent, refaddr $board2, '... got the right board');

done_testing;
