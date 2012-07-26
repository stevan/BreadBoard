package Bread::Board::Container;
use Moose;
use Moose::Util::TypeConstraints 'find_type_constraint';
use MooseX::Params::Validate;
# ABSTRACT: A container for services and other containers

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

no Moose; 1;

__END__

=pod

=head1 SYNOPSIS

  use Bread::Board;
  my $c = container MCP => as {
      container Users => as {
          service flynn => ...;
          service bradley => ...;
          service dillinger => ...;
      };

      container Programs => as {
          container Rebels => as {
              service tron => ...;
              service yori => ...;
              alias flynn => '/Users/flynn';
          };

          # nested container
          container Slaves => as {
              service sark => ...;
              service crom => ...;
          };
      };
  };

  # OR directly...
  my $guardians => Bread::Board::Container->new( name => 'Guardians' );
  $guardians->add_service(
      Bread::Board::ConstructorInjection->new(
          name => 'dumont',
          ...,
      )
  );
  $c->get_sub_container('Programs')->add_sub_container($guardians);

=head1 DESCRIPTION

Containers provide the overall layout of your L<Bread::Board>. They are analogous to folders for holding services. You must have one root container to hold your services. You can nest containers, though it is often convenient to have just a single root container.

This class also has all the features provided and required by L<Bread::Board::Traversable>.

=head1 METHODS

=over 4

=item B<add_service ( $service )>

Given a service object, this will add the service to this container. When added, the service will have the C<parent> attribute set to this container. A service cannot be placed in multiple containers. If you need to do that, you should use an C<alias> instead (see L<Bread::Board> or L<Bread::Board::Service::Alias>).

=item B<add_sub_container ( $container )>

Given a container object, this will add that container as a child container. The container will have the C<parent> attribute set to this container. A container may not have multiple parents.

=item B<get_service ( $service_name )>

This will retrieve a single service by name that has been added directly to this container. If you need to get a service from a sub-container, you will need to use the C<resolve> method instead.

=item B<get_service_list>

This will return a list of service names (not objects) for the current container.

  # Deresolution all services in the container
  for my $name ($c->get_service_list) {
      my $service = $c->get_service($name);
      $service->get->deres;
  }

=item B<get_sub_container ( $container_name )>

This will retrieve a direct sub-container of the current container. If you need to get a container from a grandchild or other relationship, you will need to use the C<fetch> method provided by L<Bread::Board::Traversable>.

=item B<get_sub_container_list>

This returns the list of sub-container names (not objects) that have been added to this container.

=item B<has_service ( $service_name )>

Given the name of a service, this will return true if this container holds a service with that name.

=item B<has_services>

Returns true if this container has one or more services within it.

=item B<has_sub_container ( $container_name )>

Given the name of a container, this will return true if this container has a sub-container with that name.

=item B<has_sub_containers>

Returns true if this container has one or more containers within it.

  # An unlikely scenario, but possible
  sub clean_up_empty_containers {
      my $c = shift;

      if (not $c->has_services and not $c->has_sub_containers) {
          delete $c->parent->sub_containers->{ $c->name };
      }

      else {
          clean_up_empty_containers( $c->get_sub_container($_) )
              for ($c->get_sub_container_list);
      }
  }

=item B<name ( ?$name )>

Returns the name of the container or may be passed a string to name the container.

=item B<services ( ?$services )>

Returns a hash reference mapping service names to service objects. Changes to this will modify the container services. 

Generally, you should prefer using C<add_service>, C<get_service>,
C<has_service>, C<get_service_list>, and C<has_services> instead of working
with this directly.

=item B<sub_containers>

Returns a hash reference mapping sub-container names to sub-container objects. Changes to this will modify the container.

Generally, you should prefer using C<add_sub_container>, C<get_sub_container>, C<has_sub_container>, C<get_sub_container_list>, and C<has_sub_containers> instead of working with this directly.

=item B<fetch ( $service_or_container_path )>

Given a path, this will traverse your L<Bread::Board> to locate the service or container object it refers to or return C<undef> if no such object exists. An exception will be thrown on error (such as using ".." on a container with no parent or if an cycle is detected trying to resolve an alias).

These paths resemble Unix file system paths. Path elements are separated by slashes ("/"). You may use a slash at the front of the path to start at the root container or no slash to use a path based on the current container. You may use a double-dot ("..") to get to the parent container of the current container.

=item B<resolve ( ?service => $service_path, ?type => $type, ?parameters => { ... } )>

Either C<$service_path> or C<$type> arguments must be passed in. This will fetch a service using the given path or type name. It will then C<get> the service with the given parameters and return the value the service is configured to construct.

=item B<add_type_mapping_for ( $type_name, $service )>

Adds a type mapping to the container.

=item B<get_type_mapping_for ( $type_name )>

Retrieves the service for a type mapping defined directly within this container.

=item B<has_type_mapping_for ( $type_name )>

Returns true if this container directly contains a type mapping for the given type name.

=item B<type_mappings ( ?$type_mapping )>

Returns a reference to the hash used to store the type mapping. The keys are the names of the types and the values are the services defined for each type mapping.

Generally, you should prefer using C<add_type_mapping_for>, C<get_type_mapping_for>, and C<has_type_mapping_for> instead of working with this directly.

=back

=head1 BUGS

All complex software has bugs lurking in it, and this module is no
exception. If you find a bug please either email me, or add the bug
to cpan-RT.

=cut





