package Bread::Board::Service::WithClass;
# ABSTRACT: role for services returning instances of a given class

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

=head1 DESCRIPTION

This a sub-role of L<Bread::Board::Service> for services that return
instances of a given class.

=attr C<class>

Read/write string attribute, the name of the class that this service
will probably instantiate.

=method C<has_class>

Predicate for the L</class> attribute, true if it has been set.

=method C<get>

This role adds a C<before> modifier to the C<get> method, ensuring
that the module implementing the L</class> is loaded.
