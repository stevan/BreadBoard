package Bread::Board;
use v5.16;
use warnings;
use mop;

use Bread::Board::Util qw(coerce_dependencies);

class BlockInjection with Bread::Board::Service::WithParameters,
                          Bread::Board::Service::WithDependencies,
                          Bread::Board::Service::WithClass {

    has $!block is rw = die '$!block is required';

    method new ($class: %args) {
        $args{'class_name'} = delete $args{'class'};
        coerce_dependencies( \%args );
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
        my $result = $self->block->($self);
        $self->clean_parameters;
        $self->clear_params;
        return $result;
    }

}

__END__

=pod

=head1 DESCRIPTION

=head1 METHODS

=over 4

=item B<block>

=item B<class>

=item B<has_class>

=item B<get>

=item B<meta>

=back

=head1 BUGS

All complex software has bugs lurking in it, and this module is no
exception. If you find a bug please either email me, or add the bug
to cpan-RT.

=cut
