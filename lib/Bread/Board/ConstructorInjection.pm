package Bread::Board::ConstructorInjection;
# ABSTRACT: service instantiating objects via a constructor

use Moose;
# ABSTRACT: Lazy service loaded using the object constructor

use Try::Tiny;

use Bread::Board::Types;

with 'Bread::Board::Service::WithConstructor',
     'Bread::Board::Service::WithParameters',
     'Bread::Board::Service::WithDependencies';

has '+class' => (required => 1);

sub get {
    my $self = shift;

    my $constructor = $self->constructor_name;
    $self->class->$constructor( %{ $self->params } );
}

__PACKAGE__->meta->make_immutable;

no Moose; 1;

__END__

=head1 DESCRIPTION

This L<service|Bread::Board::Service> class instantiates objects by
calling the constructor on a class.

This class consumes L<Bread::Board::Service::WithClass>,
L<Bread::Board::Service::WithParameters>,
L<Bread::Board::Service::WithDependencies>.

=attr C<class>

Attribute provided by L<Bread::Board::Service::WithClass>. This
service makes it a required attribute: you can't call a constructor if
you don't have a class.

=attr C<constructor_name>

Optional string, indicates the name of the class method to invoke to
construct the object. If not provided, defaults to the constructor
name obtained via L<Class::MOP::Class>, or C<new> if introspection
does not work.

=method C<get>

Calls the constructor (as indicated by L</constructor_name>) on the
L</class>, passing all the L<service
parameters|Bread::Board::Service/params> as a B<hash>. Returns
whatever the constructor returned (hopefully a correctly-constructed
object of the right class).
