package Bread::Board::Service::Deferred;
use v5.16;
use warnings;
use mop;

class Thunk {
    has $!thunk = die '$!thunk is required';

    method inflate { $!thunk->( @_ ) }
}

no mop;
__END__

=pod

=head1 DESCRIPTION

No user servicable parts. Read the source if you are interested.

=head1 BUGS

All complex software has bugs lurking in it, and this module is no
exception. If you find a bug please either email me, or add the bug
to cpan-RT.

=cut
