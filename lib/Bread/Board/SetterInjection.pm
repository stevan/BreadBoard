package Bread::Board::SetterInjection;
use Moose;

use Bread::Board::Types;

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

with 'Bread::Board::Service::WithClass',
     'Bread::Board::Service::WithDependencies',
     'Bread::Board::Service::WithParameters';

sub get {
    my $self = shift;
    my $o = $self->class->new;
    $o->$_($self->param($_)) foreach $self->param;
    return $o;
}

1;

__END__

=pod

=head1 NAME

Bread::Board::SetterInjection

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 METHODS

=over 4

=item B<>

=back

=head1 BUGS

All complex software has bugs lurking in it, and this module is no
exception. If you find a bug please either email me, or add the bug
to cpan-RT.

=head1 AUTHOR

Stevan Little E<lt>stevan@iinteractive.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright 2007-2008 by Infinity Interactive, Inc.

L<http://www.iinteractive.com>

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut