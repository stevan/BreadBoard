use Test::Requires 'Moo';

{
    package Foo;

    use Moo;

    has str => ( is => 'rw', default => '' );

    sub BUILD {
        my ($self, $args) = @_;

        $self->str($self->str);
    }

    around str => sub {
        my ($orig, $self, $val) = @_;

        return $orig->($self) unless defined $val;

        $orig->( $self, 'prefix_'.$val);
    };
}


# BB was using Class::MOP::class_of to determine
# the constructor, and that plays havoc with Moo,
# it seems
{ package Bar; use Moo; extends 'Foo'; }

{ package Baz; use Moose; extends 'Foo'; }

package main;

use strict;
use warnings;

use Test::More;

use Bread::Board;

my $c = container 'MyApp' => as {
    map {
        service lc $_ => ( 
            class => $_,
            parameters => { str => { optional => 1 } } 
        )
    } qw/ Foo Bar Baz /
};


subtest $_, \&test_class, $_ for qw/ Foo Bar Baz/;

done_testing;

sub test_class {
    my $class = shift;
    my $plain = $class->new({ str => 'foo_plain' });
    is $plain->str => 'prefix_foo_plain';

    my $bb = $c->resolve( service => lc $class, parameters => { str => 'foo_bb' } );
    is( $class->new( str => 'foo_plain' )->str => 'prefix_foo_plain', 'plain after resolve' );

    is $bb->str => 'prefix_foo_bb';
    is $plain->str => 'prefix_foo_plain', 'plain after str';

    $bb->str('foo_bb_setter');
    is $bb->str => 'prefix_foo_bb_setter';

    my $plain_after_bb = $class->new({ str => 'foo_plain_after_bb' });
    is $plain_after_bb->str => 'prefix_foo_plain_after_bb';

    is( Foo->new( str => 'foo_plain' )->str => 'prefix_foo_plain', 'Foo untouched' );
}
