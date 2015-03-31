package Bread::Board::Container;
use Moose;
use Moose::Util::TypeConstraints 'find_type_constraint';
use MooseX::Params::Validate 0.14;

use Bread::Board::Types;

with 'Bread::Board::Traversable';

has 'name' => (
    is       => 'rw',
    isa      => 'Str',
    required => 1
);

has 'services' => (
    traits    => [ 'Hash', 'Clone' ],
    is        => 'rw',
    isa       => 'Bread::Board::Container::ServiceList',
    coerce    => 1,
    lazy      => 1,
    default   => sub{ +{} },
    trigger   => sub {
        my $self = shift;
        $_->parent($self) foreach values %{$self->services};
    },
    handles  => {
        'get_service'      => 'get',
        'has_service'      => 'exists',
        'get_service_list' => 'keys',
        'has_services'     => 'count',
    }
);

has 'sub_containers' => (
    traits    => [ 'Hash', 'Clone' ],
    is        => 'rw',
    isa       => 'Bread::Board::Container::SubContainerList',
    coerce    => 1,
    lazy      => 1,
    default   => sub{ +{} },
    trigger   => sub {
        my $self = shift;
        $_->parent($self) foreach values %{$self->sub_containers};
    },
    handles  => {
        'get_sub_container'      => 'get',
        'has_sub_container'      => 'exists',
        'get_sub_container_list' => 'keys',
        'has_sub_containers'     => 'count',
    }
);

has 'type_mappings' => (
    traits  => [ 'Hash' ],
    is      => 'rw',
    isa     => 'Bread::Board::Container::ServiceList',
    lazy    => 1,
    default => sub{ +{} },
    handles => {
        '_get_type_mapping_for' => 'get',
        '_has_type_mapping_for' => 'exists',
        '_mapped_types'         => 'keys',
    }
);

sub get_type_mapping_for {
    my $self = shift;
    my ($type) = @_;

    return $self->_get_type_mapping_for($type)
        if $self->_has_type_mapping_for($type);

    for my $possible ($self->_mapped_types) {
        return $self->_get_type_mapping_for($possible)
            if $possible->isa($type);
    }

    return;
}

sub has_type_mapping_for {
    my $self = shift;
    my ($type) = @_;

    return 1
        if $self->_has_type_mapping_for($type);

    for my $possible ($self->_mapped_types) {
        return 1
            if $possible->isa($type);
    }

    return;
}

sub add_service {
    my ($self, $service) = @_;
    (blessed $service && $service->does('Bread::Board::Service'))
        || confess "You must pass in a Bread::Board::Service instance, not $service";
    $service->parent($self);
    $self->services->{$service->name} = $service;
}

sub add_sub_container {
    my ($self, $container) = @_;
    (
        blessed $container &&
        (
            $container->isa('Bread::Board::Container')
            ||
            $container->isa('Bread::Board::Container::Parameterized')
        )
    ) || confess "You must pass in a Bread::Board::Container instance, not $container";
    $container->parent($self);
    $self->sub_containers->{$container->name} = $container;
}

sub add_type_mapping_for {
    my ($self, $type, $service) = @_;

    my $type_constraint = find_type_constraint( $type );

    (defined $type_constraint)
        || confess "You must pass a valid Moose type, and it must exist already";

    (blessed $service && $service->does('Bread::Board::Service'))
        || confess "You must pass in a Bread::Board::Service instance, not $service";

    $self->type_mappings->{ $type_constraint->name } = $service;
}

sub resolve {
    my ($self, %params) = validated_hash(\@_,
        service    => { isa => 'Str',     optional => 1 },
        type       => { isa => 'Str',     optional => 1 },
        parameters => { isa => 'HashRef', optional => 1 },
    );

    my %parameters = exists $params{'parameters'}
        ? %{ $params{'parameters'} }
        : ();

    if (my $service_path = $params{'service'}) {
        my $service = $self->fetch( $service_path );
        # NOTE:
        # we might want to allow Bread::Board::Service::Deferred::Thunk
        # objects as well, but I am not sure that is a valid use case
        # for this, so for now we just don't go there.
        # - SL
        (blessed $service && $service->does('Bread::Board::Service'))
            || confess "You can only resolve services, "
                     . (defined $service ? $service : 'undef')
                     . " is not a Bread::Board::Service";
        return $service->get( %parameters );
    }
    elsif (my $type = $params{'type'}) {

        ($self->has_type_mapping_for( $type ))
            || confess "Could not find a mapped service for type ($type)";

        my $service = $self->get_type_mapping_for( $type );
        my $result  = $service->get( %parameters );

        (find_type_constraint( $type )->check( $result ))
            || confess "The result of the service for type ($type) did not"
                     . " pass the type constraint with $result";

        return $result;
    }
    else {
        confess "Cannot call resolve without telling it what to resolve.";
    }

}

__PACKAGE__->meta->make_immutable;

no Moose::Util::TypeConstraints;
no Moose;

1;

__END__

=pod

=head1 DESCRIPTION

This class implements the container for L<Bread::Board>: a container
is a thing that contains services and other containers. Each container
and service has a name, so you end up with a tree of named nodes, just
like files and directories in a filesystem: each item can be
referenced using a path (see L<Bread::Board::Traversable> for the
details).

=head1 METHODS

=over 4

=item B<name>

Read/write string, required. Every container needs a name, by which it
can be referenced when L<fetching it|Bread::Board::Traversable/fetch>.

=item B<services>

Hashref, constrained by L<<
C<Bread::Board::Container::ServiceList>|Bread::Board::Types/Bread::Board::Container::ServiceList
>>, mapping names to services directly contained in this
container. Every service added here will have its L<<
C<parent>|Bread::Board::Traversable/parent >> set to this container.

You can pass an arrayref of services instead of a hashref, the keys
will be the names of the services.

You should probably use L</add_service> and L</get_service> to
manipulate this attribute, instead of modifying it directly.

=item B<add_service>

  $container->add_service($service);

Adds a service into the L</services> map, using its name as the key.

=item B<get_service>

  my $service = $container->get_service($name);

Returns a service by name, or C<undef> if there's no such service in
the L</services> map.

=item B<has_service>

  if ($container->has_service($name)) { ... }

Returns true if a service with the given name name exists in the
L</services> map, false otherwise.

=item B<has_services>

  if ($container->has_services) { ... }

Returns true if the L</services> map contains any services, false if
it's empty.

=item B<get_service_list>

  my @service_names = $container->get_service_list();

Returns the names off all services present in the L</services> map.

=item B<sub_containers>

Hashref, constrained by L<<
C<Bread::Board::Container::SubContainerList>|Bread::Board::Types/Bread::Board::Container::SubContainerList
>>, mapping names to containers directly contained in this
container. Every container added here will have its L<<
C<parent>|Bread::Board::Traversable/parent >> set to this container.

You can pass an arrayref of containers instead of a hashref, the keys
will be the names of the containers.

You should probably use L</add_sub_container> and
L</get_sub_container> to manipulate this attribute, instead of
modifying it directly.

Containers added here can either be normal L<Bread::Board::Container>
or L<Bread::Board::Container::Parameterized>.

=item B<add_sub_container>

  $container->add_sub_container($container);

Adds a container into the L</sub_containers> map, using its name as
the key.

=item B<get_sub_container>

  my $container = $container->get_sub_container($name);

Returns a container by name, or C<undef> if there's no such container
in the L</sub_containers> map.

=item B<has_sub_container>

  if ($container->has_sub_container($name)) { ... }

Returns true if a container with the given name name exists in the
L</sub_containers> map, false otherwise.

=item B<has_sub_containers>

  if ($container->has_sub_containers) { ... }

Returns true if the L</sub_containers> map contains any contains,
false if it's empty.

=item B<get_sub_container_list>

  my @container_names = $container->get_sub_container_list();

Returns the names off all containers present in the L</sub_containers>
map.

=item B<add_type_mapping_for ( $type_name, $service )>

Adds a mapping from a L<Moose type|Moose::Util::TypeConstraints> to a
service: whenever we try to L<< resolve|/resolve ( ?service =>
$service_name, ?type => $type, ?parameters => { ... } ) >> that type,
we'll use that service to instantiate it.

=item B<get_type_mapping_for ( $type_name )>

Returns the service to use to instantiate the given type name.

Important: if a mapping for the exact type can't be found, but a
mapping for a I<subtype> of it can, you'll get the latter instead:

  package Superclass { use Moose };
  package Subclass { use Moose; exends 'Superclass' };

  $c->add_type_mapping_for(
   'Subclass',
   Bread::Board::ConstructorInjection->new(name=>'sc',class=>'Subclass'),
 );
 my $o = $c->get_type_mapping_for('Superclass')->get;

C<$o> is an instance of C<Subclass>. If there are more than one
sub-type mapped, you get a random one. This is probably a bad idea.

=item B<has_type_mapping_for ( $type_name )>

Returns true if we have a service defined to instantiate the given
type name, but see the note on
L<get_type_mapping_for|/get_type_mapping_for ( $type_name )> about
subtype mapping.

=item B<< resolve ( ?service => $service_name, ?type => $type, ?parameters => { ... } ) >>

When given a service name, this method will
L<fetch|Bread::Board::Traversable/fetch> the service, then call L<<
C<get>|Bread::Board::Service/get >> on it, optionally passing the
given parameters.

When given a type name, this method will use
L<get_type_mapping_for|/get_type_mapping_for ( $type_name )> to get
the service, then call L<< C<get>|Bread::Board::Service/get >> on it,
optionally passing the given parameters. If the instance is not of the
expected type, the method will die.

=back

=head1 BUGS

All complex software has bugs lurking in it, and this module is no
exception. If you find a bug please either email me, or add the bug
to cpan-RT.

=cut





