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

        return $self->$orig unless defined $val;

        $self->$orig('prefix_'.$val);
    };
}


{ package Bar; use Moo; extends 'Foo'; }

{ package Baz; use Moose; extends 'Foo'; }

package main;

use strict;
use warnings;

use Test::More;

use Bread::Board;

my $c = container 'MyApp' => as {
    service 'foo' => ( class => 'Foo', parameters => { str => { optional => 1 } } );
    service 'bar' => ( class => 'Bar', parameters => { str => { optional => 1 } } );
    service 'baz' => ( class => 'Baz', parameters => { str => { optional => 1 } } );
};


subtest $_, \&test_class, $_ for qw/ Foo Bar Baz/;

done_testing;

sub test_class {
    my $class = shift;
    my $plain = $class->new({ str => 'foo_plain' });
    is $plain->str => 'prefix_foo_plain';

    my $bb = $c->resolve( service => lc $class, parameters => { str => 'foo_bb' } );
    is $bb->str => 'prefix_foo_bb';

    $bb->str('foo_bb_setter');
    is $bb->str => 'prefix_foo_bb_setter';

    my $plain_after_bb = $class->new({ str => 'foo_plain_after_bb' });
    is $plain_after_bb->str => 'prefix_foo_plain_after_bb';
}
