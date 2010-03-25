package Bread::Board::Container;
use Moose;
use Moose::Util::TypeConstraints;
use MooseX::AttributeHelpers;

use Bread::Board::Types;

our $VERSION   = '0.11';
our $AUTHORITY = 'cpan:STEVAN';

with 'Bread::Board::Traversable';

has 'name' => (
    is       => 'rw',
    isa      => 'Str',
    required => 1
);

has 'services' => (
    metaclass => 'Collection::Hash',
    traits    => ['Clone'],
    is        => 'rw',
    isa       => 'Bread::Board::Container::ServiceList',
    coerce    => 1,
    lazy      => 1,
    default   => sub{ +{} },
    trigger   => sub {
        my $self = shift;
        $_->parent($self) foreach values %{$self->services};
    },
    provides  => {
        'get'    => 'get_service',
        'exists' => 'has_service',
        'keys'   => 'get_service_list',
        'empty'  => 'has_services',
    }
);

has 'sub_containers' => (
    metaclass => 'Collection::Hash',
    is        => 'rw',
    isa       => 'Bread::Board::Container::SubContainerList',
    coerce    => 1,
    lazy      => 1,
    default   => sub{ +{} },
    trigger   => sub {
        my $self = shift;
        $_->parent($self) foreach values %{$self->sub_containers};
    },
    provides  => {
        'get'    => 'get_sub_container',
        'exists' => 'has_sub_container',
        'keys'   => 'get_sub_container_list',
        'empty'  => 'has_sub_containers',
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
    (blessed $container && $container->isa('Bread::Board::Container'))
        || confess "You must pass in a Bread::Board::Container instance, not $container";
    $container->parent($self);
    $self->sub_containers->{$container->name} = $container;
}

__PACKAGE__->meta->make_immutable;

no Moose; no Moose::Util::TypeConstraints; 1;

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





