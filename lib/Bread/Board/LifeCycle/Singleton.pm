package Bread::Board::LifeCycle;
use v5.16;
use warnings;
use mop;

use Try::Tiny;

role Singleton with Bread::Board::LifeCycle {

    has $instance            is rw;
    has $resolving_singleton is rw = 0;

    method has_instance   { defined $instance }
    method flush_instance { undef $instance   }

    method get_or_create_instance ($creator) {

        # return it if we got it ...
        return $self->instance if $self->has_instance;

        my $instance;
        if ($self->resolving_singleton) {
            $instance = Bread::Board::Service::Deferred->new(service => $self);
        }
        else {
            $self->resolving_singleton(1);
            try {
                # otherwise fetch it ...
                $instance = $creator->();
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
    }

}

=pod

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

=cut

__END__

=pod

=head1 DESCRIPTION

=head1 METHODS

=over 4

=item B<get>

=item B<instance>

=item B<has_instance>

=item B<flush_instance>

=back

=head1 BUGS

All complex software has bugs lurking in it, and this module is no
exception. If you find a bug please either email me, or add the bug
to cpan-RT.

=cut
