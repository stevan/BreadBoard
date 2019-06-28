package Bread::Board::Dependency;
our $AUTHORITY = 'cpan:STEVAN';
# ABSTRACT: dependency for a service
$Bread::Board::Dependency::VERSION = '0.37';
use Moose;

use Bread::Board::Service;

with 'Bread::Board::Traversable';

has 'service_path' => (
    is        => 'ro',
    isa       => 'Str',
    predicate => 'has_service_path'
);

has 'service_name' => (
    is      => 'ro',
    isa     => 'Str',
    lazy    => 1,
    default => sub {
        my $self = shift;
        ($self->has_service_path)
            || confess "Could not determine service name without service path";
        (split '/' => $self->service_path)[-1];
    }
);

has 'service_params' => (
    is        => 'ro',
    isa       => 'HashRef',
    predicate => 'has_service_params'
);

has 'service' => (
    is       => 'ro',
    does     => 'Bread::Board::Service | Bread::Board::Dependency',
    lazy     => 1,
    default  => sub {
        my $self = shift;
        ($self->has_service_path)
            || confess "Could not fetch service without service path";
        $self->fetch($self->service_path);
    },
    handles  => [ 'get', 'is_locked', 'lock', 'unlock' ]
);

__PACKAGE__->meta->make_immutable;

no Moose; 1;

__END__

=pod

=encoding UTF-8

=head1 NAME

Bread::Board::Dependency - dependency for a service

=head1 VERSION

version 0.37

=head1 DESCRIPTION

This class holds the information for a dependency of a
L<service|Bread::Board::Service::WithDependencies>. When L<resolving
dependencies|Bread::Board::Service::WithDependencies/resolve_dependencies>,
instances of this class will be used to access the services that will
provide the depended-on values.

This class consumes the L<Bread::Board::Traversable> role to retrieve
services given their path.

=head1 ATTRIBUTES

=head2 C<service_path>

The path to use (possibly relative to the dependency itself) to access
the L</service>.

=head2 C<service>

The service this dependency points at. Usually built lazily from the
L</service_path>, but could just be passed in to the constructor.

=head2 C<service_name>

Name of the L</service>, defaults to the last element of the
L</service_path>.

=head1 METHODS

=head2 C<has_service_path>

Predicate for the L</service_path> attribute.

=head2 C<get>

=head2 C<is_locked>

=head2 C<lock>

=head2 C<unlock>

These methods are delegated to the L</service>.

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
