#!/usr/bin/perl

use strict;
use warnings;

use Test::More;
use Test::Fatal;

use Bread::Board;

{
    package Foo;
    use Moose;
    has 'bar' => (is => 'ro', isa => 'Int', required => 1);

    package Bar;
    use Moose;
    has 'foo' => (is => 'ro', isa => 'Int', required => 1);
}

my $c = container 'MyApp' => as {

    service 'foo' => (
        class      => 'Foo',
        parameters => {
            bar => { isa => 'Int' }
        }
    );

    service 'bar' => (
        class      => 'Bar',
        parameters => {
            foo => { isa => 'Int' }
        }
    );

};

my $foo;
is(exception {
    $foo = $c->resolve( service => 'foo', parameters => { bar => 10 } );
}, undef, '... got the service correctly');
isa_ok($foo, 'Foo');
is($foo->bar, 10, '... got the right parameter value');

my $bar;
is(exception {
    $bar = $c->resolve( service => 'bar', parameters => { foo => 20 } );
}, undef, '... got the service correctly');
isa_ok($bar, 'Bar');
is($bar->foo, 20, '... got the right parameter value');

done_testing;
