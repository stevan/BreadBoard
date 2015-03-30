package Bread::Board::LifeCycle;
use Moose::Role;

no Moose::Role; 1;

__END__

=pod

=head1 DESCRIPTION

This is an empty role. Roles that define L<lifecycle for
services|Bread::Board::Service/lifecycle> should consume this role.

For an example, see L<Bread::Board::LifeCycle::Singleton> and
L<Bread::Board::LifeCycle::Singleton::WithParameters>.

=head1 BUGS

All complex software has bugs lurking in it, and this module is no
exception. If you find a bug please either email me, or add the bug
to cpan-RT.

=cut
