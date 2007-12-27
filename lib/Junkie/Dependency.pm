package Junkie::Dependency;
use Moose;

use Junkie::Service;

with 'Junkie::Traversable';

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

has 'service' => (
    is       => 'ro',
    does     => 'Junkie::Service | Junkie::Dependency',
    lazy     => 1,
    default  => sub {
        my $self = shift;
        ($self->has_service_path)
            || confess "Could not fetch service without service path";        
        $self->fetch($self->service_path);
    },
    handles  => [ 'get' ]
);

1;

__END__