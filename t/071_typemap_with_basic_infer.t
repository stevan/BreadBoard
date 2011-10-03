#!/usr/bin/perl

use strict;
use warnings;

use Test::More;
use Test::Moose;

use Bread::Board;

{
    package Foo::Role;
    use Moose::Role;

    package My::Foo;
    use Moose;
    with 'Foo::Role';
}

# give infer() enough information to create
# the service all by itself ...
{
    my $c = container 'MyTestContainer' => as {
        typemap 'Foo::Role' => infer( class => 'My::Foo' );
    };

    ok($c->has_type_mapping_for('Foo::Role'), '... have a type mapping for Foo::Role');
    does_ok(
        $c->get_type_mapping_for('Foo::Role'),
        'Bread::Board::Service'
    );

    {
        my $foo = $c->resolve( type => 'Foo::Role' );
        isa_ok($foo, 'My::Foo');
    }
}

# don't give infer enough information
# and make it figure it out for itself
{
    my $c = container 'MyTestContainer' => as {
        typemap 'My::Foo' => infer;
    };

    ok($c->has_type_mapping_for('My::Foo'), '... have a type mapping for My::Foo');
    does_ok(
        $c->get_type_mapping_for('My::Foo'),
        'Bread::Board::Service'
    );

    {
        my $foo = $c->resolve( type => 'My::Foo' );
        isa_ok($foo, 'My::Foo');
    }
}

{
    my $c = container 'MyTestContainer' => as {
        typemap 'My::Foo' => infer(
            dependencies => { thing => service('thing' => 'THING') }
        );
    };

    ok($c->has_type_mapping_for('My::Foo'), '... have a type mapping for My::Foo');
    my $s = $c->get_type_mapping_for('My::Foo');
    does_ok($s, 'Bread::Board::Service');
    ok($s->has_dependency('thing'), "service_args were passed along");

    {
        my $foo = $c->resolve( type => 'My::Foo' );
        isa_ok($foo, 'My::Foo');
    }
}

{
    package My::ConstructorInjection;
    use Moose;
    extends 'Bread::Board::ConstructorInjection';
}

{
    my $c = container 'MyTestContainer' => as {
        typemap 'My::Foo' => infer(
            My::ConstructorInjection->new(
                name  => 'foo',
                class => 'My::Foo',
            )
        );
    };

    ok($c->has_type_mapping_for('My::Foo'), '... have a type mapping for My::Foo');
    my $s = $c->get_type_mapping_for('My::Foo');
    does_ok($s, 'Bread::Board::Service');
    isa_ok($s, 'My::ConstructorInjection');

    {
        my $foo = $c->resolve( type => 'My::Foo' );
        isa_ok($foo, 'My::Foo');
    }
}

done_testing;
