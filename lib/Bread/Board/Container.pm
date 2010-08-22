package Bread::Board::Container;
use Moose;
use MooseX::Params::Validate;

use Bread::Board::Types;

our $VERSION   = '0.14';
our $AUTHORITY = 'cpan:STEVAN';

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
    traits    => [ 'Hash' ],
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

has 'typemap' => (
    traits  => [ 'Hash' ],
    is      => 'rw',
    isa     => 'Bread::Board::Container::ServiceList',
    lazy    => 1,
    default => sub{ +{} },
    handles => {
        'add_type_mapping_for' => 'set',
        'get_type_mapping_for' => 'get',
        'has_type_mapping_for' => 'exists',
    }
);

# TODO:
# perhaps we should add a check to
# make sure that any type added is
# a valid Moose type.
# - SL

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

sub resolve {
    my ($self, %params) = validated_hash(\@_,
        service    => { isa => 'Str',     optional => 1 },
        type       => { isa => 'Str',     optional => 1 },
        parameters => { isa => 'HashRef', optional => 1 },
    );

    my $service;
    if (my $service_path = $params{'service'}) {
        $service = $self->fetch( $service_path );
        # NOTE:
        # we might want to allow Bread::Board::Service::Deferred::Thunk
        # objects as well, but I am not sure that is a valid use case
        # for this, so for now we just don't go there.
        # - SL
        (blessed $service && $service->does('Bread::Board::Service'))
            || confess "You can only resolve services, "
                     . (defined $service ? $service : 'undef')
                     . " is not a Bread::Board::Service";
    }
    elsif (my $type = $params{'type'}) {
        ($self->has_type_mapping_for( $type ))
            || confess "Could not find a mapped service for type ($type)";
        $service = $self->get_type_mapping_for( $type );
        # TODO:
        # perhaps we should do a type check here
        # that will tell us if all is well.
        # - SL
    }
    else {
        confess "Cannot call resolve without telling it what to resolve.";
    }

    return $service->get(
        (exists $params{'parameters'}
            ? %{ $params{'parameters'} }
            : ())
    );
}

__PACKAGE__->meta->make_immutable;

no Moose; 1;

__END__

=pod

=head1 NAME

Bread::Board::Container

=head1 DESCRIPTION

=head1 METHODS

=over 4

=item B<add_service>

=item B<add_sub_container>

=item B<get_service>

=item B<get_service_list>

=item B<get_sub_container>

=item B<get_sub_container_list>

=item B<has_service>

=item B<has_services>

=item B<has_sub_container>

=item B<has_sub_containers>

=item B<name>

=item B<services>

=item B<sub_containers>

=item B<fetch ( $service_name )>

=item B<resolve ( ?service => $service_name, ?type => $type, ?parameters => { ... } )>

=back

=head1 BUGS

All complex software has bugs lurking in it, and this module is no
exception. If you find a bug please either email me, or add the bug
to cpan-RT.

=head1 AUTHOR

Stevan Little E<lt>stevan@iinteractive.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright 2007-2010 by Infinity Interactive, Inc.

L<http://www.iinteractive.com>

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut





