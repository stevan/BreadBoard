package Bread::Board::Service::Deferred::Thunk;
use Moose;

has 'thunk' => (
    traits   => [ 'Code' ],
    is       => 'bare',
    isa      => 'CodeRef',
    required => 1,
    handles  => {
        'inflate' => 'execute'
    }
);

1;

__END__

=pod

=head1 DESCRIPTION

This class is used when L<resolving dependencies that need
parameters|Bread::Board::Service::WithDependencies/resolve_dependencies>.

Since the service needs parameters to instantiate its value, and no
values were provided for those parameters, the best we can do is use a
coderef that will accept the parameters and call C<get> on the
service.

=head1 METHODS

=over 4

=item B<inflate>

  my $service_value = $deferred_thunk->inflate(%service_parameters);

This will call C<get> on the service, passing it all the
C<%service_parameters>. Normal parameter validation and service
lifecycle apply.

=back

=head1 BUGS

All complex software has bugs lurking in it, and this module is no
exception. If you find a bug please either email me, or add the bug
to cpan-RT.

=cut
