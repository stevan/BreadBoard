package Junkie::Dependency;
use Moose;

use Junkie::Service;

with 'Junkie::Traversable';

has 'service_path' => (
    is        => 'ro', 
    isa       => 'Str',
    predicate => 'has_service_path'
);

has 'service' => (
    is       => 'ro',
    does     => 'Junkie::Service | Junkie::Dependency',
    lazy     => 1,
    default  => sub {
        my $self = shift;
        $self->fetch($self->service_path);
    },
    handles  => [ 'get' ]
);

1;

__END__