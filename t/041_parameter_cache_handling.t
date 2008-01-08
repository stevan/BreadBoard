#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 7;
use Test::Exception;

BEGIN {
    use_ok('Bread::Board');  
}

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
lives_ok {
    $foo = $c->fetch('foo')->get(bar => 10);
} '... got the service correctly';
isa_ok($foo, 'Foo');
is($foo->bar, 10, '... got the right parameter value');

my $bar;
lives_ok {
    $bar = $c->fetch('bar')->get(foo => 20);
} '... got the service correctly';
isa_ok($bar, 'Bar');
is($bar->foo, 20, '... got the right parameter value');








