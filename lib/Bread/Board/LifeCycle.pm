package Bread::Board::LifeCycle;
our $AUTHORITY = 'cpan:STEVAN';
# ABSTRACT: base lifecycle role 
$Bread::Board::LifeCycle::VERSION = '0.37';
use Moose::Role;

no Moose::Role; 1;

__END__

=pod

=encoding UTF-8

=head1 NAME

Bread::Board::LifeCycle - base lifecycle role 

=head1 VERSION

version 0.37

=head1 DESCRIPTION

This is an empty role. Roles that define L<lifecycle for
services|Bread::Board::Service/lifecycle> should consume this role.

For an example, see L<Bread::Board::LifeCycle::Singleton> and
L<Bread::Board::LifeCycle::Singleton::WithParameters>.

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
