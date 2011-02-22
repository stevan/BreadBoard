#!/usr/bin/perl

use strict;
use warnings;

use Test::More;
use Test::Moose;

BEGIN {
    use_ok('Bread::Board');
}

{
    package My::Foo;
    use Moose;

    has 'bar' => (
        is       => 'ro',
        isa      => 'My::Bar',
        required => 1
    );

    package My::Bar;
    use Moose;

    has 'foo' => (
        is       => 'ro',
        isa      => 'My::Foo',
        required => 1
    );

}

{
    my $c = container 'MyTestContainer' => as {
        typemap 'My::Foo' => infer;
    };

    ok($c->has_type_mapping_for('My::Foo'), '... have a type mapping for My::Foo');

    {
        my $foo = $c->resolve( type => 'My::Foo' );
        isa_ok($foo, 'My::Foo');
        isa_ok($foo->bar, 'My::Bar');
    }

    {
        my $bar = $c->resolve( service => 'type:My::Bar' );
        isa_ok($bar, 'My::Bar');
        isa_ok($bar->foo, 'My::Foo');
    }
}

done_testing;

