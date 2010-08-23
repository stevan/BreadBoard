#!/usr/bin/perl

use strict;
use warnings;

use Test::More;
use Test::Moose;

BEGIN {
    use_ok('Bread::Board');
}

{
    package My::Bar;
    use Moose;

    package My::Foo;
    use Moose;

    has 'bar' => (
        is       => 'ro',
        isa      => 'My::Bar',
        required => 1,
    );
}

{
    my $c = container 'MyTestContainer' => as {
        typemap 'My::Bar' => infer;
        typemap 'My::Foo' => infer;
    };

    ok($c->has_type_mapping_for('My::Foo'), '... have a type mapping for My::Foo');
    does_ok(
        $c->get_type_mapping_for('My::Foo'),
        'Bread::Board::Service'
    );
    ok($c->has_type_mapping_for('My::Bar'), '... we do not have a type mapping for My::Bar');
    does_ok(
        $c->get_type_mapping_for('My::Bar'),
        'Bread::Board::Service'
    );
    is(
        $c->get_type_mapping_for('My::Foo')->get_dependency('bar')->service,
        $c->get_type_mapping_for('My::Bar'),
        '... the My::Bar dependency for My::Foo is the same as in the type map'
    );

    {
        my $foo = $c->resolve( type => 'My::Foo' );
        isa_ok($foo, 'My::Foo');
        isa_ok($foo->bar, 'My::Bar');
    }
}

# don't give infer enough information
# and make it figure it out for itself
# including inferring the embedded object
{
    my $c = container 'MyTestContainer' => as {
        typemap 'My::Foo' => infer;
    };

    ok($c->has_type_mapping_for('My::Foo'), '... have a type mapping for My::Foo');
    does_ok(
        $c->get_type_mapping_for('My::Foo'),
        'Bread::Board::Service'
    );
    ok(!$c->has_type_mapping_for('My::Bar'), '... we do not have a type mapping for My::Bar');

    {
        my $foo = $c->resolve( type => 'My::Foo' );
        isa_ok($foo, 'My::Foo');
        isa_ok($foo->bar, 'My::Bar');
    }
}

done_testing;

