package Bread::Board::Service::WithClass;
our $AUTHORITY = 'cpan:STEVAN';
# ABSTRACT: role for services returning instances of a given class
$Bread::Board::Service::WithClass::VERSION = '0.34';
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

=encoding UTF-8

=head1 NAME

Bread::Board::Service::WithClass - role for services returning instances of a given class

=head1 VERSION

version 0.34

=head1 DESCRIPTION

This a sub-role of L<Bread::Board::Service> for services that return
instances of a given class.

=head1 ATTRIBUTES

=head2 C<class>

Read/write string attribute, the name of the class that this service
will probably instantiate.

=head1 METHODS

=head2 C<has_class>

Predicate for the L</class> attribute, true if it has been set.

=head2 C<get>

This role adds a C<before> modifier to the C<get> method, ensuring
that the module implementing the L</class> is loaded.

=head1 AUTHOR

Stevan Little <stevan@iinteractive.com>

=head1 BUGS

Please report any bugs or feature requests on the bugtracker website
https://github.com/stevan/BreadBoard/issues

When submitting a bug or request, please include a test-file or a
patch to an existing test-file that illustrates the bug or desired
feature.

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2016 by Infinity Interactive.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
