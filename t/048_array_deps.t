#!/usr/bin/perl

use strict;
use warnings;

use Test::More;

use Bread::Board::ConstructorInjection;
use Bread::Board::Literal;
use Bread::Board::Container;
use Bread::Board::Dependency;

{
    package Item;
    use Moose;

    has my_name => (is => 'ro');

    package ListOfItems;
    use Moose;

    sub as_string { join ',',map {$_->my_name} @{shift->items} }

    has 'items' => (is => 'ro', isa => 'ArrayRef');
}

subtest 'no container' => sub {
    my $s = Bread::Board::ConstructorInjection->new(
        name => 'list_of_items',
        class => 'ListOfItems',
        dependencies => {
            items => [
                map {
                    Bread::Board::ConstructorInjection->new(
                        name => $_,
                        class => 'Item',
                        dependencies => {
                            my_name => Bread::Board::Literal->new(
                                name => 'item_name',
                                value => $_,
                            ),
                        },
                    )
                  }
                    qw(one two three)
                ],
        },
    );

    my $output = $s->get->as_string;
    is(
        $output,
        'one,two,three',
        'it worked'
    );
};

subtest 'container, no ambiguous path names' => sub {
    my $c = Bread::Board::Container->new(
        name => 'list_container',
        services => [
            (map {
                Bread::Board::ConstructorInjection->new(
                    name => "item_$_",
                    class => 'Item',
                    dependencies => {
                        my_name => Bread::Board::Literal->new(
                            name => 'item_name',
                            value => $_,
                        ),
                    },
                )
              }
                 qw(one two three)),
            Bread::Board::ConstructorInjection->new(
                name => 'list_of_items',
                class => 'ListOfItems',
                dependencies => {
                    items => [ map { "item_$_" } qw(one two three) ],
                },
            ),
        ],
    );
    my $output = $c->fetch('list_of_items')->get->as_string;
    is(
        $output,
        'one,two,three',
        'it worked'
    );
};

subtest 'multiple containers, ambiguous names' => sub {
    my $c = Bread::Board::Container->new(
        name => 'list_container',
        sub_containers => [
            map { Bread::Board::Container->new(
                name => "$_",
                services => [
                    Bread::Board::ConstructorInjection->new(
                        name => "item",
                        class => 'Item',
                        dependencies => {
                            my_name => Bread::Board::Literal->new(
                                name => 'item_name',
                                value => $_,
                            ),
                        },
                    )
                  ],
            ) } qw(one two three),
        ],
        services => [
            Bread::Board::ConstructorInjection->new(
                name => 'list_of_items',
                class => 'ListOfItems',
                dependencies => {
                    # all of these have a service_name of "item", the
                    # dependency coercion must give them distinct
                    # names
                    items => [ map { "/$_/item" } qw(one two three) ],
                },
            ),
        ],
    );

    my $output = $c->fetch('list_of_items')->get->as_string;
    is(
        $output,
        'one,two,three',
        'it worked'
    );
};

done_testing;
