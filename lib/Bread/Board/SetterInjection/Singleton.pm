package Bread::Board::SetterInjection;
use v5.16;
use warnings;
use mop;

use Try::Tiny;

use Carp 'confess';
use Scalar::Util 'blessed';

use Bread::Board::Service::Deferred;

class Singleton extends Bread::Board::SetterInjection
                   with Bread::Board::LifeCycle::Singleton {

    method get (@args) {
        my $get = $self->next::can;
        $self->get_or_create_instance(sub {
            $get->($self, @args)
        });
    }

}

no mop;

__END__