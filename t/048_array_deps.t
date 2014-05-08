#!/usr/bin/perl

use strict;
use warnings;

use Test::More;

use Bread::Board::ConstructorInjection;
use Bread::Board::Literal;

{
    package Item;
    use Moose;

    has my_name => (is => 'ro');

    package ListOfItems;
    use Moose;

    sub as_string { join ',',map {$_->my_name} @{shift->items} }

    has 'items' => (is => 'ro', isa => 'ArrayRef');
}

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

done_testing;
