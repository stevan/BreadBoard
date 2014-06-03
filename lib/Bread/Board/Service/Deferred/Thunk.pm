package Bread::Board::Service::Deferred::Thunk;
BEGIN {
  $Bread::Board::Service::Deferred::Thunk::AUTHORITY = 'cpan:STEVAN';
}
$Bread::Board::Service::Deferred::Thunk::VERSION = '0.32';
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

Bread::Board::Service::Deferred::Thunk

=head1 VERSION

version 0.32

=head1 DESCRIPTION

No user servicable parts. Read the source if you are interested.

=head1 BUGS

All complex software has bugs lurking in it, and this module is no
exception. If you find a bug please either email me, or add the bug
to cpan-RT.

=head1 AUTHOR

Stevan Little <stevan@iinteractive.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2014 by Infinity Interactive.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
