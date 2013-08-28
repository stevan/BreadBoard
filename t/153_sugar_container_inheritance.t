#!/usr/bin/perl

use strict;
use warnings;

use Test::More;
use Test::Fatal;

use Bread::Board;

my $c = container Foo => as {
    container Bar => as {
        service baz => 21;
    };

    container Moo => ['Bar'] => as {
        service kooh => (
            block => sub {
                my ($s) = @_;
                $s->param('baz') * 2;
            },
            dependencies => {
                baz => depends_on('Bar/baz'),
            },
        );
    };
};

container $c => as {
    container '+Bar' => as {
        service bif => 123;
    };

    container '+Moo' => as {
        service boo => (
            block => sub {
                my ($s) = @_;
                $s->param('a') + $s->param('b');
            },
            dependencies => {
                a => depends_on('kooh'),
                b => depends_on('Bar/bif'),
            },
        );
    };
};

is $c->resolve(service => 'Bar/baz'), 21;
is $c->resolve(service => 'Bar/bif'), 123;

my $p = $c->fetch('Moo')->create(Bar => $c->fetch('Bar'));
is $p->resolve(service => 'kooh'), 42;
is $p->resolve(service => 'boo'), 165;

like exception {
    container '+Foo' => as {};
}, qr/^Inheriting containers isn't possible outside of the context of a container/;

like exception {
    container $c => as {
        container '+Buf' => as {};
    };
}, qr/^Could not find container or service for Buf in Foo/;

like exception {
    container $c => as {
        container '+Buf' => ['Moo'] => as {};
    };
}, qr/^Declaring container parameters when inheriting is not supported/;

done_testing;
