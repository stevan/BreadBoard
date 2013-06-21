package Bread::Board::BlockInjection;
use Moose;
# ABSTRACT: Lazy service loaded via custom subroutine

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
