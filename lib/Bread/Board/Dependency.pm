package Bread::Board::Dependency;
use Moose;

use Bread::Board::Service;

with 'Bread::Board::Traversable';

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
    does     => 'Bread::Board::Service | Bread::Board::Dependency',
    lazy     => 1,
    default  => sub {
        my $self = shift;
        ($self->has_service_path)
            || confess "Could not fetch service without service path";        
        $self->fetch($self->service_path);
    },
    handles  => [ 'get', 'is_locked', 'lock', 'unlock' ]
);

1;

__END__