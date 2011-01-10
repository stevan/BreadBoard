package Bread::Board::Container;
use Moose;
use Moose::Util::TypeConstraints 'find_type_constraint';
use MooseX::Params::Validate;

use Bread::Board::Types;

our $VERSION   = '0.16';
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

has 'type_mappings' => (
    traits  => [ 'Hash' ],
    is      => 'rw',
    isa     => 'Bread::Board::Container::ServiceList',
    lazy    => 1,
    default => sub{ +{} },
    handles => {
        'get_type_mapping_for' => 'get',
        'has_type_mapping_for' => 'exists',
    }
);

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

Copyright 2007-2011 by Infinity Interactive, Inc.

L<http://www.iinteractive.com>

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut





