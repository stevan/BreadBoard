package Bread::Board::Service::Alias;
our $AUTHORITY = 'cpan:STEVAN';
# ABSTRACT: aliases another service
$Bread::Board::Service::Alias::VERSION = '0.37';
use Moose;

use Try::Tiny;

has aliased_from_path => (
    is  => 'ro',
    isa => 'Str',
);

has aliased_from => (
    is      => 'ro',
    does    => 'Bread::Board::Service',
    lazy    => 1,
    builder => '_build_aliased_from',
    handles => ['get'], # is this sufficient?
);

with 'Bread::Board::Service';

sub _build_aliased_from {
    my $self = shift;

    my $path = $self->aliased_from_path;
    confess "Can't create an alias service without a service to alias from"
        unless $path;

    return try {
        $self->fetch($path);
    }
    catch {
        die "While resolving alias " . $self->name . ": $_";
    };
}

__PACKAGE__->meta->make_immutable;

no Moose; 1;

__END__

=pod

=encoding UTF-8

=head1 NAME

Bread::Board::Service::Alias - aliases another service

=head1 VERSION

version 0.37

=head1 DESCRIPTION

This L<service|Bread::Board::Service> class implements
L<aliases|Bread::Board/alias ($service_name, $service_path,
%service_description)>.

=head1 ATTRIBUTES

=head2 C<aliased_from_path>

Read-only string attribute, the path of the service this alias refers
to (it can be an alias itself)

=head2 C<aliased_from>

Lazy read-only attribute, built by calling L<<
C<fetch>|Bread::Board::Traversable/fetch >> on this service using the
L</aliased_from_path> as path to fetch

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
