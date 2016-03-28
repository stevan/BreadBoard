#!/usr/bin/perl

use strict;
use warnings;

use Test::More;
use Test::Fatal;

use Bread::Board;

my $c = container Foo => as {
    container Bar => ['Baz'] => as {
        service moo => (
            block => sub {
                my ($s) = @_;
                $s->param('kooh');
            },
            dependencies => {
                kooh => depends_on('Baz/boo'),
            },
        );
    };

    container Bif => as {
        service boo => 42;
    };
};

is $c->fetch('Bar')->create(Baz => $c->fetch('Bif'))->resolve(service => 'moo'), 42, 'container works as expected';

my $clone;
is exception { $clone = $c->clone }, undef, 'cloning the container does not throw an exception';

is $clone->fetch('Bar')->create(Baz => $clone->fetch('Bif'))->resolve(service => 'moo'), 42, 'clone behaves like the original';

done_testing;
