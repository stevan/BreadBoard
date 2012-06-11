#!/usr/bin/env perl
use strict;
use warnings;
use Test::More;

use Bread::Board;

my $c = container Foo => as {
    service a => 'A';
    service foo => (
        block        => sub { $_[0]->param('a'); },
        dependencies => ['a'],
        parameters   => {
            # XXX should optional need to be specified here? or should an
            # existing dependency of the same name imply that? seems to
            # parallel the default/required situation in moose, where default
            # overrides required, but not sure
            a => { optional => 1 },
        },
    );
};

is($c->resolve(service => 'foo'), 'A');
is($c->resolve(service => 'foo', parameters => { a => 'B' }), 'B');

done_testing;
