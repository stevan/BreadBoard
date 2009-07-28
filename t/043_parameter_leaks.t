#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 6;
use Test::Exception;

BEGIN {
    use_ok('Bread::Board');
}

{
    package Foo;
    use Moose;
    has 'bar' => (is => 'ro', isa => 'Bar', required => 1);

    package Bar;
    use Moose;

    our $BAR_DEMOLISH_COUNT = 0;

    sub DESTROY {
        $BAR_DEMOLISH_COUNT++;
    }
}

my $c = container 'MyApp' => as {

    service 'foo' => (
        class      => 'Foo',
        parameters => {
            bar => { isa => 'Bar' }
        }
    );
};

{
    my $bar = Bar->new;

    {
        my $foo;
        lives_ok {
            $foo = $c->fetch('foo')->get(bar => $bar);
        } '... got the service correctly';
        isa_ok($foo, 'Foo');
        is($foo->bar, $bar, '... got the right parameter value');
    }

    is($Bar::BAR_DEMOLISH_COUNT, 0, '... it should be one');

    # $bar should be demolished here ...
}

is($Bar::BAR_DEMOLISH_COUNT, 1, '... it should be one');




