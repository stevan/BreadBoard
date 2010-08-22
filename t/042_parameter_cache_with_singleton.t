#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 27;
use Test::Exception;

BEGIN {
    use_ok('Bread::Board');
    use_ok('Bread::Board::LifeCycle::Singleton::WithParameters');
}

{
    package Foo;
    use Moose;
    has 'bar' => (is => 'ro', isa => 'Int', required => 1);
    has 'baz' => (is => 'ro', isa => 'Str', required => 1);
}

my $c = container 'MyApp' => as {

    service 'foo' => (
        lifecycle  => 'Singleton::WithParameters',
        class      => 'Foo',
        parameters => {
            bar => { isa => 'Int' },
            baz => { isa => 'Str' },
        }
    );

};

my $foo;
lives_ok {
    $foo = $c->resolve( service => 'foo', parameters => { bar => 10, baz => 'BAZ' } );
} '... got the service correctly';
isa_ok($foo, 'Foo');
is($foo->bar, 10, '... got the right parameter value');
is($foo->baz, 'BAZ', '... got the right parameter value');

# this is the same instance ...
my $foo2;
lives_ok {
    $foo2 = $c->resolve( service => 'foo', parameters => { bar => 10, baz => 'BAZ' } );
} '... got the service correctly';
isa_ok($foo2, 'Foo');
is($foo2->bar, 10, '... got the right parameter value');
is($foo2->baz, 'BAZ', '... got the right parameter value');

# this will be different instance ...
my $foo3;
lives_ok {
    $foo3 = $c->resolve( service => 'foo', parameters => { bar => 20, baz => 'BAZ' } );
} '... got the service correctly';
isa_ok($foo3, 'Foo');
is($foo3->bar, 20, '... got the right parameter value');
is($foo3->baz, 'BAZ', '... got the right parameter value');

# this is the same instance ...
my $foo4;
lives_ok {
    $foo4 = $c->resolve( service => 'foo', parameters => { bar => 10, baz => 'BAZ' } );
} '... got the service correctly';
isa_ok($foo4, 'Foo');
is($foo4->bar, 10, '... got the right parameter value');
is($foo4->baz, 'BAZ', '... got the right parameter value');

# this will be different instance ...
my $foo5;
lives_ok {
    $foo5 = $c->resolve( service => 'foo', parameters => { bar => 10, baz => 'Baz' });
} '... got the service correctly';
isa_ok($foo5, 'Foo');
is($foo5->bar, 10, '... got the right parameter value');
is($foo5->baz, 'Baz', '... got the right parameter value');

# confirm our assumptions ...

is($foo, $foo2, '... they are the same instances (same params)');
isnt($foo, $foo3, '... they are not the same instances (diff params)');
is($foo, $foo4, '... they are the same instances (same params)');
isnt($foo, $foo5, '... they are the same instances (same params)');
isnt($foo3, $foo5, '... they are the same instances (same params)');









