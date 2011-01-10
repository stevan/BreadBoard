package Bread::Board::Service::WithClass;
use Moose::Role;

use Bread::Board::Types;

our $VERSION   = '0.16';
our $AUTHORITY = 'cpan:STEVAN';

with 'Bread::Board::Service';

has 'class' => (
    is       => 'rw',
    isa      => 'Str',
    required => 1,
);

before 'get' => sub {
    Class::MOP::load_class((shift)->class)
};

no Moose::Role; 1;

__END__

=pod

=head1 NAME

Bread::Board::Service::WithClass

=head1 DESCRIPTION

=head1 METHODS

=over 4

=item B<class>

=item B<get>

=back

=head1 BUGS

All complex software has bugs lurking in it, and this module is no
exception. If you find a bug please either email me, or add the bug
to cpan-RT.

=head1 AUTHOR

Stevan Little E<lt>stevan@iinteractive.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright 2007-2011 by Infinity Interactive, Inc.

L<http://www.iinteractive.com>

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
