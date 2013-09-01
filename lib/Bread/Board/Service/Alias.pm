package Bread::Board::Service;
use v5.16;
use warnings;
use mop;

use Carp 'confess';
use Scalar::Util 'blessed';
use Try::Tiny;

class Alias with Bread::Board::Service {
    has $!aliased_from_path is ro;

    has $!aliased_from is ro, lazy = $_->_build_aliased_from;

    method get { $!aliased_from->get( @_ ) }

    method _build_aliased_from {
        my $path = $self->aliased_from_path;
        confess "Can't create an alias service without a service to alias from"
            unless $path;

        return try {
            $self->fetch($path);
        } catch {
            die "While resolving alias " . $self->name . ": $_";
        };
    }
}

__END__

=pod

=head1 DESCRIPTION

No user servicable parts. Read the source if you are interested.

=head1 BUGS

All complex software has bugs lurking in it, and this module is no
exception. If you find a bug please either email me, or add the bug
to cpan-RT.

=begin Pod::Coverage

aliased_from_path
aliased_from
_build_aliased_from

=end Pod::Coverage

=cut
