#!/usr/bin/perl

use strict;
use warnings;

use Test::More;

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

    {
        my $foo = $c->resolve( type => 'Foo::Role' );
        isa_ok($foo, 'My::Foo');
    }
}

# don't give infer enough information
# and make it figure it out for itself
{
    my $c = container 'MyTestContainer' => as {
        typemap 'My::Foo' => infer();
    };

    {
        my $foo = $c->resolve( type => 'My::Foo' );
        isa_ok($foo, 'My::Foo');
    }
}

done_testing;

