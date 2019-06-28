package Bread::Board::BlockInjection;
our $AUTHORITY = 'cpan:STEVAN';
# ABSTRACT: service instantiated via custom subroutine
$Bread::Board::BlockInjection::VERSION = '0.37';
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

=pod

=encoding UTF-8

=head1 NAME

Bread::Board::BlockInjection - service instantiated via custom subroutine

=head1 VERSION

version 0.37

=head1 DESCRIPTION

This L<service|Bread::Board::Service> class instantiates objects by
calling a coderef supplied in the L</block> attribute.

This class consumes L<Bread::Board::Service::WithClass>,
L<Bread::Board::Service::WithParameters>,
L<Bread::Board::Service::WithDependencies>.

=head1 ATTRIBUTES

=head2 C<block>

A coderef, required. Will be invoked as a method on the service
object, so it can call L<<< C<< $_[0]->params
>>|Bread::Board::Service/params >>> to access parameters and (resolved)
dependencies. It should return an instance of L</class>.

=head2 C<class>

Attribute provided by L<Bread::Board::Service::WithClass>; if it is
set, L</block> should return an instance of this class (and the class
will be already loaded, so there's no need to C<require> it).

=head1 METHODS

=head2 C<has_class>

Predicate for L</class>. If the service does not declare a class, the
L</block> can of course return whatever it wants.

=head2 C<get>

Calls the L</block> as a method on the service, and returns whatever
that returned.

=head1 AUTHOR

Stevan Little <stevan@iinteractive.com>

=head1 BUGS

Please report any bugs or feature requests on the bugtracker website
https://github.com/stevan/BreadBoard/issues

When submitting a bug or request, please include a test-file or a
patch to an existing test-file that illustrates the bug or desired
feature.

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2019, 2017, 2016, 2015, 2014, 2013, 2011, 2009 by Infinity Interactive.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
