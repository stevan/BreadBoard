package Bread::Board;
use v5.16;
use warnings;
use mop;

class Literal with Bread::Board::Service {

    has $!value is rw = die '$!value is required';

    method get { $!value }
}

no mop;
__END__

=pod

=head1 DESCRIPTION

=head1 METHODS

=over 4

=item B<get>

=item B<value>

=back

=head1 BUGS

All complex software has bugs lurking in it, and this module is no
exception. If you find a bug please either email me, or add the bug
to cpan-RT.

=cut
