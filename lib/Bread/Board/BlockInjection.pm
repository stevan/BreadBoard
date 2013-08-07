package Bread::Board;
use v5.16;
use warnings;
use mop;

class BlockInjection with Bread::Board::Service::WithParameters,
                          Bread::Board::Service::WithDependencies,
                          Bread::Board::Service::WithClass {

    has $block is rw = die '$block is required';

    method new (%args) {
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
        my $result = $self->block->($self);
        $self->clean_parameters;
        $self->clear_params;
        return $result;
    }

}

=pod

package Bread::Board::BlockInjection;
use Moose;

with 'Bread::Board::Service::WithParameters',
     'Bread::Board::Service::WithDependencies',
     'Bread::Board::Service::WithClass';

has 'block' => (
    is       => 'rw',
    isa      => 'CodeRef',
    required => 1,
);


sub get {
    my $self = shift;
    $self->block->($self)
}
__PACKAGE__->meta->make_immutable;

no Moose; 1;

=cut

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
