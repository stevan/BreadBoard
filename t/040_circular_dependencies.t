#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 25;
use Test::Moose;

BEGIN {
    use_ok('Bread::Board');
}

=pod

This test checks the basic cyclical dependency
handling. It is not quite as sophisticated as
the IOC one, but it is good enough. Honestly,
in all the years of using IOC, I never needed
to use cyclical deps.

=cut

{
    package Class::A;
    use Moose;
    has 'B' => (is => 'ro', isa => 'Class::B');
    package Class::B;
    use Moose;
    has 'A' => (is => 'ro', isa => 'Class::A');

    package Class::C;
    use Moose;
    has 'D' => (is => 'ro', isa => 'Class::D');
    package Class::D;
    use Moose;
    has 'E' => (is => 'ro', isa => 'Class::E');
    package Class::E;
    use Moose;
    has 'F' => (is => 'ro', isa => 'Class::F');
    package Class::F;
    use Moose;
    has 'C' => (is => 'ro', isa => 'Class::C');
}


#     +---+
#  +--| A |<-+
#  |  +---+  |
#  |  +---+  |
#  +->| B |--+
#     +---+

{
    my $c = container 'Test' => as {

        service 'A' => (
            class        => 'Class::A',
            lifecycle    => 'Singleton',
            dependencies => [ depends_on('B') ]
        );

        service 'B' => (
            class        => 'Class::B',
            lifecycle    => 'Singleton',
            dependencies => [ depends_on('A') ]
        );

    };
    isa_ok($c, 'Bread::Board::Container');

    ok($c->has_service('A'), '... got the A service');
    ok($c->has_service('B'), '... got the B service');

    my $b = $c->resolve( service => 'B' );
    isa_ok($b, 'Class::B');

    my $a = $c->resolve( service => 'A');
    isa_ok($a, 'Class::A');

    isa_ok($b->A, 'Class::A');
    isa_ok($a->B, 'Class::B');

    is($a->B, $b, '... our Bs match');
    is($b->A, "$a", '... our As match');

}


#       +---+
#    +--| C |<-+
#    |  +---+  |
#  +-V-+     +---+
#  | D |     | F |
#  +---+     +-^-+
#    |  +---+  |
#    +->| E |--+
#       +---+

{
    my $container = container 'Test' => as {

        service 'C' => (
            class        => 'Class::C',
            lifecycle    => 'Singleton',
            dependencies => [ depends_on('D') ]
        );

        service 'D' => (
            class        => 'Class::D',
            lifecycle    => 'Singleton',
            dependencies => [ depends_on('E') ]
        );

        service 'E' => (
            class        => 'Class::E',
            lifecycle    => 'Singleton',
            dependencies => [ depends_on('F') ]
        );

        service 'F' => (
            class        => 'Class::F',
            lifecycle    => 'Singleton',
            dependencies => [ depends_on('C') ]
        );

    };
    isa_ok($container, 'Bread::Board::Container');

    ok($container->has_service($_), '... got the ' . $_ . ' service') for qw/C D E F/;

    my $c = $container->resolve( service => 'C' );
    isa_ok($c, 'Class::C');

    my $d = $container->resolve( service => 'D' );
    isa_ok($d, 'Class::D');

    my $e = $container->resolve( service => 'E' );
    isa_ok($e, 'Class::E');

    my $f = $container->resolve( service => 'F' );
    isa_ok($f, 'Class::F');

    isa_ok($c->D, 'Class::D');
    isa_ok($d->E, 'Class::E');
    isa_ok($e->F, 'Class::F');
    isa_ok($f->C, 'Class::C');

    is($f->C, $c, '... our Cs match');
    is($c->D->E->F, $f, '... our Fs match');
}



