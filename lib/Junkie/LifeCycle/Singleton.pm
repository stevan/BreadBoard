package Junkie::LifeCycle::Singleton;
use Moose::Role;

with 'Junkie::LifeCycle';

has 'instance' => (
    is        => 'rw', 
    isa       => 'Any',
    predicate => 'has_instance',
    clearer   => 'flush_instance'
);

around 'get' => sub {
    my $next = shift;
    my $self = shift;
    return $self->instance if $self->has_instance;
    $self->instance($self->$next(@_));
};

1;

__END__