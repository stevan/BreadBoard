package Bread::Board::Container::FromParameterized;
our $AUTHORITY = 'cpan:STEVAN';
# ABSTRACT: container with weak parent reference
$Bread::Board::Container::FromParameterized::VERSION = '0.37';
use Moose;

extends 'Bread::Board::Container';

has '+parent' => (
    weak_ref => 0,
);

__PACKAGE__->meta->make_immutable;

no Moose; 1;

__END__

=pod

=encoding UTF-8

=head1 NAME

Bread::Board::Container::FromParameterized - container with weak parent reference

=head1 VERSION

version 0.37

=head1 DESCRIPTION

When L<creating|Bread::Board::Container::Parameterized/create (
%params )> an actual container from a L<parameterized
container|Bread::Board::Container::Parameterized>, the returned
container is re-blessed into this class.

The only difference between this class and L<Bread::Board::Container>
is that the C<parent> attribute here is a weak reference.

=head1 AUTHOR

Stevan Little <stevan@iinteractive.com>

=head1 BUGS

Please report any bugs or feature requests on the bugtracker website
https://github.com/stevan/BreadBoard/issues

When submitting a bug or request, please include a test-file or a
patch to an existing test-file that illustrates the bug or desired
feature.

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2019, 2017, 2016, 2015, 2014, 2013, 2011, 2009 by Infinity Interactive.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
