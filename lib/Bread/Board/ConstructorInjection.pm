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
