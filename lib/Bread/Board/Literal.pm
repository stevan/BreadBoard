package Bread::Board::Literal;
use Moose;

with 'Bread::Board::Service';

has 'value' => (
    is       => 'rw',
    isa      => 'Defined',
    required => 1,
);

sub get { (shift)->value }

sub clone_and_inherit_params {
    confess 'Trying to inherit from a literal service';
}

__PACKAGE__->meta->make_immutable;

no Moose; 1;

__END__

=head1 DESCRIPTION

This L<service|Bread::Board::Service> class implements literal
services. A literal service is costructed with a value, and it always
returns that when asked for an instance.

=attr C<value>

Required attribute with read/write accessor. This is the value that
L</get> will return.

=method C<get>

Returns the L</value>, unaltered.

=method C<clone_and_inherit_params>

Dies: a literal service is (essentially) a constant, it does not make
sense to inherit from it.
