package Bread::Board::Service::WithDependencies;
use Moose::Role;

use Try::Tiny;

use Bread::Board::Types;
use Bread::Board::Service::Deferred;
use Bread::Board::Service::Deferred::Thunk;

with 'Bread::Board::Service';

has 'dependencies' => (
    traits    => [ 'Hash', 'Clone' ],
    is        => 'rw',
    isa       => 'Bread::Board::Service::Dependencies',
    lazy      => 1,
    coerce    => 1,
    default   => sub { +{} },
    trigger   => sub {
        my $self = shift;
        $_->parent($self) foreach values %{$self->dependencies};
    },
    handles  => {
        'add_dependency'       => 'set',
        'get_dependency'       => 'get',
        'has_dependency'       => 'exists',
        'has_dependencies'     => 'count',
        'get_all_dependencies' => 'kv',
    }
);

around 'init_params' => sub {
    my $next = shift;
    my $self = shift;
    +{ %{ $self->$next() }, $self->resolve_dependencies }
};

after 'get' => sub { (shift)->clear_params };

sub resolve_dependencies {
    my $self = shift;
    my %deps;
    if ($self->has_dependencies) {
        foreach my $dep ($self->get_all_dependencies) {
            my ($key, $dependency) = @$dep;

            my $service = $dependency->service;

            # NOTE:
            # this is what checks for
            # circular dependencies
            if ($service->is_locked) {

                confess "You cannot defer a parameterized service"
                    if $service->does('Bread::Board::Service::WithParameters')
                    && $service->has_parameters;

                $deps{$key} = Bread::Board::Service::Deferred->new(service => $service);
            }
            else {
                # since we can't pass in parameters here,
                # we return a deferred thunk and you can do
                # with it what you will.
                if (
                    $service->does('Bread::Board::Service::WithParameters')
                    &&
                    $service->has_required_parameters
                    &&
                    (not $service->has_parameter_defaults)
                    &&
                    (not $dependency->has_service_params)
                   ) {
                    $deps{$key} = Bread::Board::Service::Deferred::Thunk->new(
                        thunk => sub {
                            my %params = @_;
                            $service->lock;
                            return try { $service->get( %params ) }
                               finally { $service->unlock }
                                 catch { die $_ }
                        }
                    );
                }
                else {
                    $service->lock;
                    try {
                        $deps{$key} = $dependency->has_service_params
                            ? $service->get( %{ $dependency->service_params })
                            : $service->get;
                    } finally {
                        $service->unlock
                    } catch {
                        die $_
                    };
                }
            }
        }
    }
    return %deps;
}

no Moose::Role; 1;

__END__

=head1 DESCRIPTION

This is a sub-role of L<Bread::Board::Service>, for services with
dependencies. It provides the mechanism to recursively resolve
dependencies.

=attr C<dependencies>

Hashref, constrained by L<<
C<Bread::Board::Service::Dependencies>|Bread::Board::Types/Bread::Board::Service::Dependencies
>>. Values must be instances of L<Bread::Board::Dependency>, but can
be coerced from various other types, see L<the type's
docs|Bread::Board::Types/Bread::Board::Service::Dependencies>.

=method C<add_dependency>

  $service->add_dependency(name=>$dep);

Adds a new dependency.

=method C<get_dependency>

  my $dep = $service->get_dependency('name');

Gets a dependency by name.

=method C<has_dependency>

  if ($service->has_dependency('name')) { ... }

Returns true if this service has a dependency with the given name.

=method C<has_dependencies>

  if ($service->has_dependencies) { ... }

Returns true if this service has any dependency.

=method C<get_all_dependencies>

  my %deps = $service->get_all_dependencies;

Returns all the dependencies for this service, as a key-value list.

=method C<init_params>

Builder for the service parameters, augmented to inject all the
L<resolved dependencies|/resolve_dependencies> into the L<<
C<params>|Bread::Board::Service/params >> attribute, so that C<get>
can use them.

=method C<get>

I<After> the C<get> method, the L<<
C<params>|Bread::Board::Service/params >> attribute is cleared, to
make sure that dependencies will be resolved again on the next call (of
course, if the service is using a L<singleton
lifecycle|Bread::Board::LifeCycle::Singleton>, the whole "getting"
only happens once).

=method C<resolve_dependencies>

  my %name_object_map = $self->resolve_dependencies;

For each element of L</dependencies>, calls its L<<
C<service>|Bread::Board::Dependency/service >> method to retrieve the
service we're dependent on, then tries to instantiate the value of the
service. This can happen in a few different ways:

=begin :list

= the service is not locked, and does not require any parameter

just call C<get> on it

= the service is not locked, requires parameters, but the dependency has values for them

call C<< $service->get(%{$dependency->service_params}) >>

= the service is not locked, requires parameters, and we don't have values for them

we can't instantiate anything at this point, so we use a
L<Bread::Board::Service::Deferred::Thunk> instance, on which you can
call the C<inflate> method, passing it all the needed parameters, to
get the actual instance

= the service is locked

we return a L<Bread::Board::Service::Deferred> that will proxy to the
instance that the service will eventually return; yes, this means that
in many cases circular dependencies can be resolved, at the cost of a
proxy object

=end :list
