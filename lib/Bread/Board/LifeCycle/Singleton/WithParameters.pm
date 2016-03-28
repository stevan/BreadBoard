package Bread::Board::LifeCycle::Singleton::WithParameters;
# ABSTRACT: singleton lifecycle role for a parameterized service

use Moose::Role;

with 'Bread::Board::LifeCycle';

has 'instances' => (
    traits    => [ 'Hash', 'NoClone' ],
    is        => 'rw',
    isa       => 'HashRef',
    lazy      => 1,
    default   => sub { +{} },
    clearer   => 'flush_instances',
    handles  => {
        'has_instance_at_key' => 'exists',
        'get_instance_at_key' => 'get',
        'set_instance_at_key' => 'set',
    }
);

around 'get' => sub {
    my $next = shift;
    my $self = shift;
    my $key  = $self->generate_instance_key(@_);

    # return it if we got it ...
    return $self->get_instance_at_key($key)
        if $self->has_instance_at_key($key);

    # otherwise fetch it ...
    my $instance = $self->$next(@_);

    # if we get a copy, and our copy
    # has not already been set ...
    $self->set_instance_at_key($key => $instance)
        unless $self->has_instance_at_key($key);

    # return whatever we have ...
    return $self->get_instance_at_key($key);
};

sub generate_instance_key {
    my ($self, @args) = @_;
    return "$self" unless @args;
    return join "|" => sort map { "$_" } @args
}

no Moose::Role; 1;

__END__

=head1 DESCRIPTION

Sub-role of L<Bread::Board::LifeCycle>, this role defines the
"singleton" lifecycle for a parameterized service. The C<get> method
will only do its work the first time it is invoked for each set of
parameters; subsequent invocations with the same parameters will
return the same object.

=method C<get>

Generates a key using L</generate_instance_key> (passing it all the
arguments); if the L</instances> attribute does not hold an object for
that key, it will build it (by calling the underlying C<get> method)
and store it in L</instances>. The object (either retrieved from
L</instances> or freshly built) will be returned.

=attr C<instances>

Hashref mapping keys to objects, used to cache the results of L</get>

=method C<generate_instance_key>

Generates a (hopefully) unique key from the given arguments (usually,
whatever was passed to L</get>). The current implementation
stringifies all arguments, so different references to identical values
will be considered different.
