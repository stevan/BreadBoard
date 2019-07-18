package Bread::Board::Service::WithRoles;
use Moose::Role;

use Bread::Board::Types;

with 'Bread::Board::Service';

has 'roles' => (
    is        => 'rw',
    isa       => 'ArrayRef[Str]',
    traits    => ['Array'],
    lazy      => 1,
    default   => sub { +[] },
    handles   => {
        has_roles  => 'count',
        list_roles => 'elements',
    },
);

before 'get' => sub {
    my $self = shift;

    if ( $self->has_roles ) {
		
        foreach my $role ( $self->list_roles ) {
            Module::Runtime::use_package_optimistically( $role );
        }
        my $class = Moose::Util::with_traits( $self->class, $self->list_roles );
        $class->meta->make_immutable if $self->has_roles;
		$self->class( $class );
    }
};

no Moose::Role; 1;
