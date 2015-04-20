package Bread::Board::Container::FromParameterized;
use Moose;

extends 'Bread::Board::Container';

has '+parent' => (
    weak_ref => 0,
);

__PACKAGE__->meta->make_immutable;

no Moose; 1;
__END__

=head1 DESCRIPTION

When L<creating|Bread::Board::Container::Parameterized/create (
%params )> an actual container from a L<parameterized
container|Bread::Board::Container::Parameterized>, the returned
container is re-blessed into this class.

The only difference between this class and L<Bread::Board::Container>
is that the C<parent> attribute here is a weak reference.
