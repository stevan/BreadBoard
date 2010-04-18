#!/usr/bin/perl

use strict;
use warnings;

use Test::More;
use Test::Exception;
use Test::Moose;
use Scalar::Util 'blessed';

BEGIN {
    use_ok('Bread::Board::BlockInjection');
    use_ok('Bread::Board::Literal');
}

my $s = Bread::Board::BlockInjection->new(
    name  => 'NoClass',
    block => sub {
        my $s = shift;
        return +{ foo => $s->param('foo') }
    },
    dependencies => {
        foo => Bread::Board::Literal->new( name => 'foo', value => 'FOO' )
    }
);
isa_ok($s, 'Bread::Board::BlockInjection');
does_ok($s, 'Bread::Board::Service::WithDependencies');
does_ok($s, 'Bread::Board::Service::WithParameters');
does_ok($s, 'Bread::Board::Service');

my $x = $s->get;
ok( !blessed($x), '... the result of the block injection is not blessed');

is_deeply($x, { foo => 'FOO' }, '... block injections can return unblessed values');

done_testing;