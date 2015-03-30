package Bread::Board::Dependency;
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

=head1 DESCRIPTION

This class holds the information for a dependency of a
L<service|Bread::Board::Service::WithDependencies>. When L<resolving
dependencies|Bread::Board::Service::WithDependencies/resolve_dependencies>,
instances of this class will be used to access the services that will
provide the depended-on values.

This class consumes the L<Bread::Board::Traversable> role to retrieve
services given their path.

=head1 METHODS

=over 4

=item B<service_path>

The path to use (possibly relative to the dependency itself) to access
the L</service>.

=item B<has_service_path>

Predicate for the L</service_path> attribute.

=item B<service>

The service this dependency points at. Usually built lazyly from the
L</service_path>, but could just be passed in to the constructor.

=item B<service_name>

Name of the L</service>, defaults to the last element of the
L</service_path>.

=item B<get>

=item B<is_locked>

=item B<lock>

=item B<unlock>

These methods are delegated to the L</service>.

=back

=head1 BUGS

All complex software has bugs lurking in it, and this module is no
exception. If you find a bug please either email me, or add the bug
to cpan-RT.

=cut
