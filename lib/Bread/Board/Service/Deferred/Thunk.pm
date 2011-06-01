package Bread::Board::Service::Deferred::Thunk;
use Moose;

our $VERSION   = '0.19';
our $AUTHORITY = 'cpan:STEVAN';

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

=head1 NAME

Bread::Board::Service::Deferred::Thunk

=head1 DESCRIPTION

No user servicable parts. Read the source if you are interested.

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
