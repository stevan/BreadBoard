package Junkie::Service::WithDependencies;
use Moose::Role;

use Junkie::Types;
use Junkie::Service::Deferred;

our $VERSION = '0.01';

with 'Junkie::Service';

has 'dependencies' => (
    metaclass => 'Collection::Hash',
    is        => 'rw',
    isa       => 'Junkie::Service::Dependencies',
    lazy      => 1,
    coerce    => 1,
    default   => sub { +{} },
    trigger   => sub {
        my $self = shift;
        $_->parent($self) foreach values %{$self->dependencies};        
    },
    provides  => {
        'set'    => 'add_dependency',
        'get'    => 'get_dependency',
        'exists' => 'has_dependency',        
        'empty'  => 'has_dependencies',
        'kv'     => 'get_all_dependencies',
    }
);

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
                    if $service->does('Junkie::Service::WithParameters') 
                    && $service->has_parameters;
                    
                $deps{$key} = Junkie::Service::Deferred->new(service => $service);
            }
            else {
                $service->lock;
                $deps{$key} = eval { $service->get };
                $service->unlock;            
                if ($@) { die $@ }
            }
        }
    }  
    return %deps;  
}

around 'init_params' => sub {
    my $next = shift;
    my $self = shift;
    +{ %{ $self->$next() }, $self->resolve_dependencies }
};


1;

__END__

=pod

=cut