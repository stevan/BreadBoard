#!/usr/bin/env perl
use strict;
use Test::More;

use Bread::Board;

my $seen;

{
    package Bot;
    use Moose;

    has plugin => (
        isa      => 'Plugin',
        is       => 'ro',
        required => 1
    );
}

{
    package Plugin;
    use Moose;

    has bot => (
        isa      => 'Bot',
        is       => 'ro',
        weak_ref => 1,
        required => 1
    );
}

my $c = container 'Config' => as {
    service plugin => (
        class        => 'Plugin',
        lifecycle    => 'Singleton',
        dependencies => ['bot'],
    );

    service bot => (
        class        => 'Bot',
        block        => sub {
            my ($s) = @_;
            $seen++;
            Bot->new(plugin => $s->param('plugin'));
        },
        lifecycle    => 'Singleton',
        dependencies => ['plugin'],
    );
};

ok($c->resolve(service => 'bot'));
is($seen, 1, 'seen only once');

done_testing;
