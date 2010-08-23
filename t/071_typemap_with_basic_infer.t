#!/usr/bin/perl

use strict;
use warnings;

use Test::More;
use Test::Moose;

BEGIN {
    use_ok('Bread::Board');
}

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

done_testing;

