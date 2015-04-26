package Bread::Board::Literal;
BEGIN {
  $Bread::Board::Literal::AUTHORITY = 'cpan:STEVAN';
}
$Bread::Board::Literal::VERSION = '0.33';
use Moose;

with 'Bread::Board::Service';

has 'value' => (
    is       => 'rw',
    isa      => 'Defined',
    required => 1,
);

sub get { (shift)->value }

sub clone_and_inherit_params {
    confess 'Trying to inherit from a literal service';
}

__PACKAGE__->meta->make_immutable;

no Moose; 1;

__END__

=pod

=encoding UTF-8

=head1 NAME

Bread::Board::Literal

=head1 VERSION

version 0.33

=head1 DESCRIPTION

This L<service|Bread::Board::Service> class implements literal
services. A literal service is constructed with a value, and it always
returns that when asked for an instance.

=head1 ATTRIBUTES

=head2 C<value>

Required attribute with read/write accessor. This is the value that
L</get> will return.

=head1 METHODS

=head2 C<get>

Returns the L</value>, unaltered.

=head2 C<clone_and_inherit_params>

Dies: a literal service is (essentially) a constant, it does not make
sense to inherit from it.

=head1 AUTHOR

Stevan Little <stevan@iinteractive.com>

=head1 BUGS

Please report any bugs or feature requests on the bugtracker website
https://github.com/stevan/BreadBoard/issues

When submitting a bug or request, please include a test-file or a
patch to an existing test-file that illustrates the bug or desired
feature.

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2015 by Infinity Interactive.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
