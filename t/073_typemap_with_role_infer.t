#!/usr/bin/perl

use strict;
use warnings;

use Test::More;
use Test::Exception;
use Test::Moose;

BEGIN {
    use_ok('Bread::Board');
}

{
    package Bar::Role;
    use Moose::Role;

    package My::Bar;
    use Moose;

    with 'Bar::Role';

    package My::Foo;
    use Moose;

    has 'bar' => (
        is       => 'ro',
        does     => 'Bar::Role',
        required => 1,
    );
}

{
    my $c = container 'MyTestContainer' => as {
        typemap 'Bar::Role' => infer( class => 'My::Bar' );
        typemap 'My::Foo'   => infer;
    };

    ok($c->has_type_mapping_for('My::Foo'), '... have a type mapping for My::Foo');
    does_ok(
        $c->get_type_mapping_for('My::Foo'),
        'Bread::Board::Service'
    );
    ok($c->has_type_mapping_for('Bar::Role'), '... we do have a type mapping for Bar::Role');
    does_ok(
        $c->get_type_mapping_for('Bar::Role'),
        'Bread::Board::Service'
    );
    is(
        $c->get_type_mapping_for('My::Foo')->get_dependency('bar')->service,
        $c->get_type_mapping_for('Bar::Role'),
        '... the Bar::Role dependency for My::Foo is the same as in the type map'
    );

    {
        my $foo = $c->resolve( type => 'My::Foo' );
        isa_ok($foo, 'My::Foo');
        isa_ok($foo->bar, 'My::Bar');
        does_ok($foo->bar, 'Bar::Role');
    }
}

{
    throws_ok {
        container 'MyTestContainer' => as {
            typemap 'My::Foo' => infer;
        }
    } qr/We can only infer Moose classes\, Bar\:\:Role is a role/,
    '... we can detect the role and error accordingly';
}

done_testing;

