package Bread::Board::Service::Alias;
# ABSTRACT: aliases another service

use Moose;
# ABSTRACT: Symbolic links for services

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

=head1 DESCRIPTION

This L<service|Bread::Board::Service> class implements
L<aliases|Bread::Board/alias ($service_name, $service_path,
%service_description)>.

=attr C<aliased_from_path>

Read-only string attribute, the path of the service this alias refers
to (it can be an alias itself)

=attr C<aliased_from>

Lazy read-only attribute, built by calling L<<
C<fetch>|Bread::Board::Traversable/fetch >> on this service using the
L</aliased_from_path> as path to fetch
