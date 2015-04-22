package Bread::Board::ConstructorInjection;
BEGIN {
  $Bread::Board::ConstructorInjection::AUTHORITY = 'cpan:STEVAN';
}
$Bread::Board::ConstructorInjection::VERSION = '0.33';
use Moose;

use Try::Tiny;

use Bread::Board::Types;

with 'Bread::Board::Service::WithClass',
     'Bread::Board::Service::WithParameters',
     'Bread::Board::Service::WithDependencies';

has 'constructor_name' => (
    is       => 'rw',
    isa      => 'Str',
    lazy     => 1,
    builder  => '_build_constructor_name',
);

has '+class' => (required => 1);

sub _build_constructor_name {
    my $self = shift;

    try { Class::MOP::class_of($self->class)->constructor_name } || 'new';
}

sub get {
    my $self = shift;

    my $constructor = $self->constructor_name;
    $self->class->$constructor( %{ $self->params } );
}

__PACKAGE__->meta->make_immutable;

no Moose; 1;

__END__

=pod

=encoding UTF-8

=head1 NAME

Bread::Board::ConstructorInjection

=head1 VERSION

version 0.33

=head1 DESCRIPTION

This L<service|Bread::Board::Service> class instantiates objects by
calling the constructor on a class.

This class consumes L<Bread::Board::Service::WithClass>,
L<Bread::Board::Service::WithParameters>,
L<Bread::Board::Service::WithDependencies>.

=head1 ATTRIBUTES

=head2 C<class>

Attribute provided by L<Bread::Board::Service::WithClass>. This
service makes it a required attribute: you can't call a constructor if
you don't have a class.

=head2 C<constructor_name>

Optional string, indicates the name of the class method to invoke to
construct the object. If not provided, defaults to the constructor
name obtained via L<Class::MOP::Class>, or C<new> if introspection
does not work.

=head1 METHODS

=head2 C<get>

Calls the constructor (as indicated by L</constructor_name>) on the
L</class>, passing all the L<service
parameters|Bread::Board::Service/params> as a B<hash>. Returns
whatever the constructor returned (hopefully a correctly-constructed
object of the right class).

=head1 AUTHOR

Stevan Little <stevan@iinteractive.com>

=head1 BUGS

Please report any bugs or feature requests on the bugtracker website
https://github.com/stevan/BreadBoard/issues

When submitting a bug or request, please include a test-file or a
patch to an existing test-file that illustrates the bug or desired
feature.

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2015 by Infinity Interactive.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
