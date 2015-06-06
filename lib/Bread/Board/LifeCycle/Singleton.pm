package Bread::Board::LifeCycle::Singleton;

use Moose::Role;

use Try::Tiny;

with 'Bread::Board::LifeCycle';

has 'instance' => (
    traits    => [ 'NoClone' ],
    is        => 'rw',
    isa       => 'Any',
    predicate => 'has_instance',
    clearer   => 'flush_instance'
);

has 'resolving_singleton' => (
    traits  => [ 'NoClone' ],
    is      => 'rw',
    isa     => 'Bool',
    default => 0,
);

around 'get' => sub {
    my $next = shift;
    my $self = shift;

    # return it if we got it ...
    return $self->instance if $self->has_instance;

    my $instance;
    if ($self->resolving_singleton) {
        $instance = Bread::Board::Service::Deferred->new(service => $self);
    }
    else {
        $self->resolving_singleton(1);
        my @args = @_;
        try {
            # otherwise fetch it ...
            $instance = $self->$next(@args);
        }
        catch {
            die $_;
        }
        finally {
            $self->resolving_singleton(0);
        };
    }

    # if we get a copy, and our copy
    # has not already been set ...
    $self->instance($instance);

    # return whatever we have ...
    return $self->instance;
};

no Moose::Role; 1;

__END__

=head1 DESCRIPTION

Sub-role of L<Bread::Board::LifeCycle>, this role defines the
"singleton" lifecycle for a service. The C<get> method will only do
its work the first time it is invoked; subsequent invocations will
return the same object.

=method C<get>

The first time this is called (or the first time after calling
L</flush_instance>), the actual C<get> method will be invoked, and its
return value cached in the L</instance> attribute. The value of that
attribute will always be returned, so you can call C<get> as many time
as you need, and always receive the same instance.

=attr C<instance>

The object build by the last call to C<get> to actually do any work,
and returned by any subsequent call to C<get>.

=method C<has_instance>

Predicate for the L</instance> attribute.

=method C<flush_instance>

Clearer for the L</instance> attribute. Clearing the attribute will
cause the next call to C<get> to instantiate a new object.
