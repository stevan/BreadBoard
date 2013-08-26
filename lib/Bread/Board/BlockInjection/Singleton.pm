package Bread::Board::BlockInjection;
use v5.16;
use warnings;
use mop;

use Try::Tiny;

use Carp 'confess';
use Scalar::Util 'blessed';

use Bread::Board::Service::Deferred;

class Singleton extends Bread::Board::BlockInjection
                   with Bread::Board::LifeCycle::Singleton {

    method get {

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
                $instance = $self->next::method(@args);
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

no mop;

__END__