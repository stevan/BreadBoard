package Bread::Board::Service::WithClass;
use Moose::Role;
use Module::Runtime ();

use Bread::Board::Types;

with 'Bread::Board::Service';

has 'class' => (
    is        => 'rw',
    isa       => 'Str',
    predicate => 'has_class',
);

before 'get' => sub {
    my $self = shift;
    Module::Runtime::require_module($self->class)
        if $self->has_class;
};

no Moose::Role; 1;

__END__

=pod

=head1 DESCRIPTION

This a sub-role of L<Bread::Board::Service> for services that return
instances of a given class.

=head1 METHODS

=over 4

=item B<class>

Reaw/write string attribute, the name of the class that this service
will probably instantiate.

=item B<has_class>

Predicate for the L</class> attribute, true if it has been set.

=item B<get>

This role adds a C<before> modifier to the C<get> method, ensuring
that the module implementing the L</class> is loaded.

=back

=head1 BUGS

All complex software has bugs lurking in it, and this module is no
exception. If you find a bug please either email me, or add the bug
to cpan-RT.

=cut
