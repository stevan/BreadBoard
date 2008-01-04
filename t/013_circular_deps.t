#!/usr/bin/perl

use strict;
use warnings;

use Test::More no_plan => 1;
use Test::Moose;
use Test::Exception;

BEGIN {
    use_ok('Junkie');
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
    package Class::B;
    use Moose;
    package Class::C;
    use Moose;
    package Class::D;
    use Moose;
    package Class::E;
    use Moose;            
    package Class::F;
    use Moose;    
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
            dependencies => [ depends_on('B') ]
        );
    
        service 'B' => (
            class        => 'Class::B',
            dependencies => [ depends_on('A') ]
        );    
    
    };
    isa_ok($c, 'Junkie::Container');

    ok($c->has_service('A'), '... got the A service');
    ok($c->has_service('B'), '... got the B service');

    my $a = $c->fetch('A')->get;
    isa_ok($a, 'Class::A');
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
    my $c = container 'Test' => as {
    
        service 'C' => (
            class        => 'Class::C',
            dependencies => [ depends_on('D') ]
        );
    
        service 'D' => (
            class        => 'Class::D',
            dependencies => [ depends_on('E') ]
        );
            
        service 'E' => (
            class        => 'Class::E',
            dependencies => [ depends_on('F') ]
        );        
        
        service 'F' => (
            class        => 'Class::F',
            dependencies => [ depends_on('F') ]
        );        
    
    };
    isa_ok($c, 'Junkie::Container');

    ok($c->has_service($_), '... got the ' . $_ . ' service') for qw/C D E F/;

    my $a = $c->fetch('C')->get;
    isa_ok($a, 'Class::C');
}



