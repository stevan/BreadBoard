package Bread::Board::Service::WithClass;
use Moose::Role;

use Bread::Board::Types;

with 'Bread::Board::Service';

has 'class' => (
    is        => 'rw',
    isa       => 'Str',
    predicate => 'has_class',
);

before 'get' => sub {
    my $self = shift;
    Class::MOP::load_class($self->class)
        if $self->has_class;
};

no Moose::Role; 1;

__END__

=pod

=head1 DESCRIPTION

=head1 METHODS

=over 4

=item B<class>

=item B<get>

=back

=head1 BUGS

All complex software has bugs lurking in it, and this module is no
exception. If you find a bug please either email me, or add the bug
to cpan-RT.

=cut
