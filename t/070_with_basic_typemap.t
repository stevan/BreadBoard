#!/usr/bin/perl

use strict;
use warnings;

use Test::More;

use Bread::Board;

{
    package My::Foo;
    use Moose;
}

{
    # typemap directly getting a service object ...
    my $c = container 'MyTestContainer' => as {
        typemap 'My::Foo' => (service 'my_foo' => (class => 'My::Foo'));
    };

    ok($c->has_type_mapping_for('My::Foo'), '... have a type mapping for My::Foo');
    is(
        $c->get_type_mapping_for('My::Foo'),
        $c->fetch('my_foo'),
        '... the type mapping for My::Foo is the my_foo service'
    );

    {
        my $foo = $c->resolve( service => 'my_foo' );
        isa_ok($foo, 'My::Foo');
    }
    {
        my $foo = $c->resolve( type => 'My::Foo' );
        isa_ok($foo, 'My::Foo');
    }
}

{
    # typemap mapping to a service object name ...
    my $c = container 'MyTestContainer' => as {
        service 'my_foo' => (class => 'My::Foo');
        typemap 'My::Foo' => 'my_foo';
    };

    ok($c->has_type_mapping_for('My::Foo'), '... have a type mapping for My::Foo');
    is(
        $c->get_type_mapping_for('My::Foo'),
        $c->fetch('my_foo'),
        '... the type mapping for My::Foo is the my_foo service'
    );

    {
        my $foo = $c->resolve( service => 'my_foo' );
        isa_ok($foo, 'My::Foo');
    }
    {
        my $foo = $c->resolve( type => 'My::Foo' );
        isa_ok($foo, 'My::Foo');
    }
}

{
    # typemap mapping to a service object name
    # that is a path to a sub-container service
    my $c = container 'MyTestContainer' => as {

        container 'MyTestSubContainer' => as {
            service 'my_foo' => (class => 'My::Foo');
        };

        typemap 'My::Foo' => 'MyTestSubContainer/my_foo';
    };

    ok($c->has_type_mapping_for('My::Foo'), '... have a type mapping for My::Foo');
    is(
        $c->get_type_mapping_for('My::Foo'),
        $c->fetch('MyTestSubContainer/my_foo'),
        '... the type mapping for My::Foo is the MyTestSubContainer/my_foo service'
    );

    {
        my $foo = $c->resolve( service => 'MyTestSubContainer/my_foo' );
        isa_ok($foo, 'My::Foo');
    }
    {
        my $foo = $c->resolve( type => 'My::Foo' );
        isa_ok($foo, 'My::Foo');
    }
}

done_testing;
