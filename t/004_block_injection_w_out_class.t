#!/usr/bin/perl

use strict;
use warnings;

use Test::More;
use Test::Moose;
use Scalar::Util 'blessed';

use Bread::Board::BlockInjection;
use Bread::Board::Literal;
use Bread::Board::Dependency;

my $s = Bread::Board::BlockInjection->new(
    name  => 'NoClass',
    block => sub {
        my $s = shift;
        return +{ foo => $s->param('foo') }
    },
    dependencies => {
        foo => Bread::Board::Dependency->new(service => Bread::Board::Literal->new( name => 'foo', value => 'FOO' ))
    }
);
isa_ok($s, 'Bread::Board::BlockInjection');
ok($s->does('Bread::Board::Service::WithClass'), '... does the WithClass role');
ok($s->does('Bread::Board::Service::WithDependencies'), '... does the WithDependencies role');
ok($s->does('Bread::Board::Service::WithParameters'), '... does the WithParameters role');
ok($s->does('Bread::Board::Service'), '... does the base Service role');

my $x = $s->get;
ok( !blessed($x), '... the result of the block injection is not blessed');

is_deeply($x, { foo => 'FOO' }, '... block injections can return unblessed values');

done_testing;
