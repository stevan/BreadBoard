package Bread::Board;
use v5.16;
use warnings;
use mop;

use Carp 'confess';
use Scalar::Util 'blessed';

class SetterInjection with Bread::Board::Service::WithClass,
                           Bread::Board::Service::WithParameters,
                           Bread::Board::Service::WithDependencies {

    method new (%args) {
        confess '$class is required'
            unless exists $args{'class'};
        $args{'class_name'} = delete $args{'class'};
        $class->next::method( %args );
    }

    submethod BUILD {
        $_->parent($self) foreach values %{ $self->dependencies };
    }

    method init_params {
        # NOTE:
        # this is tricky, cause we need to call
        # the underlying init_params in Service
        # but we can't easily do that since it
        # is a role.
        # - SL
        +{ %{ +{} }, $self->resolve_dependencies }
    }

    method get {
        $self->get_class;
        $self->prepare_parameters( @_ );
        my $o = $self->class->new;
        $o->$_($self->param($_)) foreach $self->param;
        $self->clean_parameters;
        $self->clear_params;
        return $o;
    }
}

=pod

package Bread::Board::SetterInjection;
use Moose;

use Bread::Board::Types;

with 'Bread::Board::Service::WithClass',
     'Bread::Board::Service::WithParameters',
     'Bread::Board::Service::WithDependencies';

has '+class' => (required => 1);

sub get {
    my $self = shift;
    my $o = $self->class->new;
    $o->$_($self->param($_)) foreach $self->param;
    return $o;
}

__PACKAGE__->meta->make_immutable;

no Moose; 1;

=cut

__END__

=pod

=head1 DESCRIPTION

=head1 METHODS

=over 4

=item B<get>

=back

=head1 BUGS

All complex software has bugs lurking in it, and this module is no
exception. If you find a bug please either email me, or add the bug
to cpan-RT.

=cut
