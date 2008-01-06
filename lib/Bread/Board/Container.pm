
package Bread::Board::Container;
use Moose;
use Moose::Util::TypeConstraints;
use MooseX::AttributeHelpers;

use Bread::Board::Types;

with 'Bread::Board::Traversable';

has 'name' => (
    is       => 'rw', 
    isa      => 'Str', 
    required => 1
);

has 'services' => (
    metaclass => 'Collection::Hash',
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


1;

__END__





