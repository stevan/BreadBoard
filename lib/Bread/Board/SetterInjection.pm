package Bread::Board::SetterInjection;
use Moose;

use Bread::Board::Types;

with 'Bread::Board::Service::WithClass',
     'Bread::Board::Service::WithParameters',
     'Bread::Board::Service::WithDependencies';

has '+class' => (required => 1);

sub get {
    my $self = shift;
    my $o = $self->class->new;
    $o->$_($self->param($_)) foreach $self->param;
    return $o;
}

__PACKAGE__->meta->make_immutable;

no Moose; 1;

__END__

=pod

=head1 DESCRIPTION

This L<service|Bread::Board::Service> class instantiates objects by
calling C<new> on a class, then calling setters on the returned
object.

This class consumes L<Bread::Board::Service::WithClass>,
L<Bread::Board::Service::WithParameters>,
L<Bread::Board::Service::WithDependencies>.

=head1 METHODS

=over 4

=item B<class>

Attribute provided by L<Bread::Board::Service::WithClass>. This
service makes it a required attribute: you can't call a constructor if
you don't have a class.

=item B<get>

Calls the C<new> method on the L</class> to get the object to return;
then, for each of the L<service
parameters|Bread::Board::Service/params>, calls a setter with the same
name as the parameter, passing it the parameter's value.

=back

=head1 BUGS

All complex software has bugs lurking in it, and this module is no
exception. If you find a bug please either email me, or add the bug
to cpan-RT.

=cut
