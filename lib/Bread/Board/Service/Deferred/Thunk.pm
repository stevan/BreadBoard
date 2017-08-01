package Bread::Board::Service::Deferred::Thunk;
our $AUTHORITY = 'cpan:STEVAN';
# ABSTRACT: Helper for using services with incomplete parameters
$Bread::Board::Service::Deferred::Thunk::VERSION = '0.35';
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

=encoding UTF-8

=head1 NAME

Bread::Board::Service::Deferred::Thunk - Helper for using services with incomplete parameters

=head1 VERSION

version 0.35

=head1 DESCRIPTION

This class is used when L<resolving dependencies that need
parameters|Bread::Board::Service::WithDependencies/resolve_dependencies>.

Since the service needs parameters to instantiate its value, and no
values were provided for those parameters, the best we can do is use a
coderef that will accept the parameters and call C<get> on the
service.

=head1 METHODS

=head2 C<inflate>

  my $service_value = $deferred_thunk->inflate(%service_parameters);

This will call C<get> on the service, passing it all the
C<%service_parameters>. Normal parameter validation and service
lifecycle apply.

=head1 AUTHOR

Stevan Little <stevan@iinteractive.com>

=head1 BUGS

Please report any bugs or feature requests on the bugtracker website
https://github.com/stevan/BreadBoard/issues

When submitting a bug or request, please include a test-file or a
patch to an existing test-file that illustrates the bug or desired
feature.

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2017, 2016, 2015, 2014, 2013, 2011, 2009 by Infinity Interactive.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
