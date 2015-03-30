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

=pod

=head1 DESCRIPTION

This L<service|Bread::Board::Service> class implements literal
services. A literal service is costructed with a value, and it always
returns that when asked for an instance.

=head1 METHODS

=over 4

=item B<value>

Required attribute with read/write accessor. This is the value that
L</get> will return.

=item B<get>

Returns the L</value>, unaltered.

=item B<clone_and_inherit_params>

Dies: a literal service is (essentially) a constant, it does not make
sense to inherit from it.

=back

=head1 BUGS

All complex software has bugs lurking in it, and this module is no
exception. If you find a bug please either email me, or add the bug
to cpan-RT.

=cut
