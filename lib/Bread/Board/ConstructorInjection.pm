package Bread::Board;
use v5.16;
use warnings;
use mop;

use Bread::Board::Util qw(coerce_dependencies);

use Carp 'confess';
use Scalar::Util 'blessed';

class ConstructorInjection with Bread::Board::Service::WithClass,
                                Bread::Board::Service::WithParameters,
                                Bread::Board::Service::WithDependencies {

    has $constructor_name is rw, lazy = $_->_build_constructor_name;

    method new (%args) {
        confess '$class is required'
            unless exists $args{'class'};
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
        my $result = $self->class->$constructor_name( %{ $self->params } );
        $self->clean_parameters;
        $self->clear_params;
        return $result;
    }

    method _build_constructor_name { 'new' }
}

=pod

package Bread::Board::ConstructorInjection;
use Moose;

use Try::Tiny;

use Bread::Board::Types;

with 'Bread::Board::Service::WithClass',
     'Bread::Board::Service::WithParameters',
     'Bread::Board::Service::WithDependencies';

has 'constructor_name' => (
    is       => 'rw',
    isa      => 'Str',
    lazy     => 1,
    builder  => '_build_constructor_name',
);

has '+class' => (required => 1);

sub _build_constructor_name {
    my $self = shift;

    try { Class::MOP::class_of($self->class)->constructor_name } || 'new';
}

sub get {
    my $self = shift;

    my $constructor = $self->constructor_name;
    $self->class->$constructor( %{ $self->params } );
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
