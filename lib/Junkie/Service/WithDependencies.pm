package Junkie::Service::WithDependencies;
use Moose::Role;

use Junkie::Types;

our $VERSION = '0.01';

with 'Junkie::Service';

has 'dependencies' => (
    metaclass => 'Collection::Hash',
    is        => 'ro',
    isa       => 'Junkie::Service::Dependencies',
    lazy      => 1,
    default   => sub { +{} },
    provides  => {
        'set'   => 'add_dependency',
        'empty' => 'has_dependencies',
        'kv'    => 'get_all_dependencies',
    }
);

sub resolve_dependencies {
    my $self = shift;
    my %deps;
    if ($self->has_dependencies) {
        foreach my $dep ($self->get_all_dependencies) {
            my ($key, $service) = @$dep;
            $deps{$key} = $service->get;
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