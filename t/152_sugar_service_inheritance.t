#!/usr/bin/perl

use strict;
use warnings;

use Test::More;
use Test::Fatal;

use Bread::Board;

{
    package Thing;
    use Moose;

    has foo => (is => 'ro', required => 1);
    has moo => (is => 'ro', required => 1);

    no Moose;

    __PACKAGE__->meta->make_immutable;
}

{
    package TestThing;
    use Moose;

    extends 'Thing';

    has bar  => (is => 'ro', required => 1);
    has kooh => (is => 'ro', required => 1);

    no Moose;

    __PACKAGE__->meta->make_immutable;
}

{
    my $c = container 'MyApp' => as {
        service foo => 42;

        service thing => (
            class        => 'Thing',
            dependencies => [depends_on('foo')],
            parameters   => {
                moo => { isa => 'Int' },
            },
        );
    };

    {
        my $t = $c->resolve(
            service    => 'thing',
            parameters => {
                moo => 123,
            },
        );

        isa_ok $t, 'Thing';
        is $t->foo, 42;
        is $t->moo, 123;
    }

    container $c => as {
        service bar => 23;

        service '+thing' => (
            class        => 'TestThing',
            dependencies => [depends_on('bar')],
            parameters   => ['kooh'],
        );
    };

    {
        my $t = $c->resolve(
            service    => 'thing',
            parameters => {
                moo  => 123,
                kooh => 456,
            },
        );

        isa_ok $t, 'TestThing';
        is $t->foo, 42;
        is $t->moo, 123;
        is $t->bar, 23;
        is $t->kooh, 456;
    }
}

like exception {
    service '+foo' => 42;
}, qr/^Service inheritance doesn't make sense for literal services/;

like exception {
    container Foo => as {
        container foo => as {};
        service '+foo' => (block => sub { 42 });
    };
}, qr/^Trying to inherit from service 'foo', but found a Bread::Board::Container/;

like exception {
    container Foo => as {
        service foo => 42;
        service '+foo' => (block => sub { 123 });
    };
}, qr/^Trying to inherit from a literal service/;

{
    package Bread::Board::FooInjection;
    use Moose;
    extends 'Bread::Board::Literal';
    no Moose;
}

like exception {
    container Foo => as {
        service foo => (block => sub { 123 });
        service '+foo' => (service_class => 'Bread::Board::FooInjection');
    };
}, qr/^Changing a service's class is not possible when inheriting/;

like exception {
    container Foo => as {
        service foo => (block => sub { 123 });
        service '+foo' => (service_type => 'Foo');
    };
}, qr/^Changing a service's class is not possible when inheriting/;

{
    package Foo;
    use Moose;
    no Moose;
}

like exception {
    container Foo => as {
        service foo => (block => sub { 123 });
        service '+foo' => (class => 'Foo');
    };
}, qr/^/;

like exception {
    container Foo => as {
        service foo => (class => 'Foo');
        service '+foo' => (block => sub { 123 });
    };
}, qr/^/;

done_testing;
