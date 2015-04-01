package Bread::Board::LifeCycle;
use Moose::Role;

no Moose::Role; 1;

__END__

=head1 DESCRIPTION

This is an empty role. Roles that define L<lifecycle for
services|Bread::Board::Service/lifecycle> should consume this role.

For an example, see L<Bread::Board::LifeCycle::Singleton> and
L<Bread::Board::LifeCycle::Singleton::WithParameters>.
