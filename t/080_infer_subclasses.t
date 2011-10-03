#!/usr/bin/env perl
use strict;
use warnings;
use Test::More;

use Bread::Board;

{
    package NonMoose;
    sub new { bless { data => $_[0] }, shift }
}

{
    package Foo;
    use Moose;

    has non_moose => (
        is       => 'ro',
        isa      => 'NonMoose',
        required => 1,
    );
}

{
    package Bar;
    use Moose;

    has foo => (
        is       => 'ro',
        isa      => 'Foo',
        required => 1,
    );
}

{
    my $c = container Stuff => as {
        service non_moose => NonMoose->new("foo");
        service foo => (
            class        => 'Foo',
            dependencies => ['non_moose'],
        );
        typemap 'Foo' => 'foo';
        typemap 'Bar' => infer;
    };

    my $bar = $c->resolve(type => 'Bar');
    isa_ok($bar->foo->non_moose, 'NonMoose');
}

{
    package Foo::Sub;
    use Moose;

    extends 'Foo';
}

{
    my $c = container Stuff => as {
        service non_moose => NonMoose->new("foo");
        service foo => (
            class        => 'Foo::Sub',
            dependencies => ['non_moose'],
        );
        typemap 'Foo::Sub' => 'foo';
        typemap 'Bar' => infer;
    };

    my $bar = $c->resolve(type => 'Bar');
    isa_ok($bar->foo->non_moose, 'NonMoose');
}

done_testing;
