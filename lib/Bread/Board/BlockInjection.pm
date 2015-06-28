package Bread::Board::BlockInjection;
# ABSTRACT: provides CodeRef-based injection

use Moose;

with 'Bread::Board::Service::WithParameters',
     'Bread::Board::Service::WithDependencies',
     'Bread::Board::Service::WithClass';

has 'block' => (
    is       => 'rw',
    isa      => 'CodeRef',
    required => 1,
);


sub get {
    my $self = shift;
    $self->block->($self)
}

__PACKAGE__->meta->make_immutable;

no Moose; 1;

__END__

=head1 DESCRIPTION

This L<service|Bread::Board::Service> class instantiates objects by
calling a coderef supplied in the L</block> attribute.

This class consumes L<Bread::Board::Service::WithClass>,
L<Bread::Board::Service::WithParameters>,
L<Bread::Board::Service::WithDependencies>.

=attr C<block>

A coderef, required. Will be invoked as a method on the service
object, so it can call L<<< C<< $_[0]->params
>>|Bread::Board::Service/params >>> to access parameters and (resolved)
dependencies. It should return an instance of L</class>.

=attr C<class>

Attribute provided by L<Bread::Board::Service::WithClass>; if it is
set, L</block> should return an instance of this class (and the class
will be already loaded, so there's no need to C<require> it).

=method C<has_class>

Predicate for L</class>. If the service does not declare a class, the
L</block> can of course return whatever it wants.

=method C<get>

Calls the L</block> as a method on the service, and returns whatever
that returned.
