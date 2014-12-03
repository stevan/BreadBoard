#!/usr/bin/perl

use strict;
use warnings;

use Test::More;
use Test::Fatal;
use Bread::Board;

my $bar = 'original';

my $c = container 'MyApp' => as {
    service foo => (
        block => sub {
            die 'Argh!' if $_[0]->param('die');
            return $_[0]->param('bar');
        },
        parameters => {
            die => { default => 0 }
        },
        dependencies => ['bar'],
    );

    service bar => (
        block => sub { $bar }
    );
};

like(exception {
    $c->resolve(service => 'foo', parameters => { die => 1 });
}, qr/^Argh!/, 'Exception is propagated...');

{
    local $TODO = 'Fix caching bug.';

    $bar = 'updated';
    is($c->resolve(service => 'foo'), $bar, 
        '... and dependency is recalculated subsequently');
}

$bar = 'updated, again';
is($c->resolve(service => 'foo'), $bar, 
    '... and subsequently, again');

done_testing;
