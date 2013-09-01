package Bread::Board;
use v5.16;
use warnings;
use mop;

use Carp 'confess';
use Scalar::Util 'blessed';

role Service with Bread::Board::Traversable {
    has $!name      is rw       = die '$!name is required';
    has $!params    is rw, lazy = $_->init_params;
    has $!is_locked is rw       = 0;

    method clear_params      { undef $!params }
    method _clear_param ($k) { delete $!params->{$k} }

    method init_params { +{} }

    method param {
        return keys %{$!params}    if scalar @_ == 0;
        return $!params->{ $_[0] } if scalar @_ == 1;
        ((scalar @_ % 2) == 0)
            || confess "parameter assignment must be an even numbered list";
        my %new = @_;
        while (my ($key, $value) = each %new) {
            $!params->{ $key } = $value;
        }
        return;
    }

    method get;

    method lock   { $!is_locked = 1 }
    method unlock { $!is_locked = 0 }

}

__END__

=pod

=head1 DESCRIPTION

=head1 METHODS

=over 4

=item B<name>

=item B<is_locked>

=item B<lock>

=item B<unlock>

=item B<lifecycle>

=item B<get>

=item B<init_params>

=item B<param>

=back

=head1 BUGS

All complex software has bugs lurking in it, and this module is no
exception. If you find a bug please either email me, or add the bug
to cpan-RT.

=cut
