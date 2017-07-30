package Bread::Board::Service::WithConstructor;

use Moose::Role;

use Try::Tiny;

with 'Bread::Board::Service::WithClass';

has 'constructor_name' => (
    is       => 'rw',
    isa      => 'Str',
    lazy     => 1,
    builder  => '_build_constructor_name',
);

sub _build_constructor_name {
    my $self = shift;

    # using Class::MOP::class_of on a Moo 
    # object causes mayhem, so we take care of that
    # special case first. See GH#61
    try { $self->class->isa('Moo::Object') && 'new' }
    || try { Class::MOP::class_of($self->class)->constructor_name } 
    || 'new';
}

no Moose; 1;

__END__

=pod

=head1 DESCRIPTION

=head1 METHODS

=over 4

=item B<constructor_name>

=back

=head1 BUGS

All complex software has bugs lurking in it, and this module is no
exception. If you find a bug please either email me, or add the bug
to cpan-RT.

=cut
