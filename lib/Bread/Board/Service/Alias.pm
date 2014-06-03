package Bread::Board::Service::Alias;
BEGIN {
  $Bread::Board::Service::Alias::AUTHORITY = 'cpan:STEVAN';
}
$Bread::Board::Service::Alias::VERSION = '0.32';
use Moose;

use Try::Tiny;

has aliased_from_path => (
    is  => 'ro',
    isa => 'Str',
);

has aliased_from => (
    is      => 'ro',
    does    => 'Bread::Board::Service',
    lazy    => 1,
    builder => '_build_aliased_from',
    handles => ['get'], # is this sufficient?
);

with 'Bread::Board::Service';

sub _build_aliased_from {
    my $self = shift;

    my $path = $self->aliased_from_path;
    confess "Can't create an alias service without a service to alias from"
        unless $path;

    return try {
        $self->fetch($path);
    }
    catch {
        die "While resolving alias " . $self->name . ": $_";
    };
}

__PACKAGE__->meta->make_immutable;

no Moose; 1;

__END__

=pod

=encoding UTF-8

=head1 NAME

Bread::Board::Service::Alias

=head1 VERSION

version 0.32

=head1 DESCRIPTION

No user servicable parts. Read the source if you are interested.

=head1 BUGS

All complex software has bugs lurking in it, and this module is no
exception. If you find a bug please either email me, or add the bug
to cpan-RT.

=for Pod::Coverage aliased_from_path
aliased_from
_build_aliased_from

=head1 AUTHOR

Stevan Little <stevan@iinteractive.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2014 by Infinity Interactive.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
