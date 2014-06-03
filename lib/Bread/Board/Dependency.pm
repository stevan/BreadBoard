package Bread::Board::Dependency;
BEGIN {
  $Bread::Board::Dependency::AUTHORITY = 'cpan:STEVAN';
}
$Bread::Board::Dependency::VERSION = '0.32';
use Moose;

use Bread::Board::Service;

with 'Bread::Board::Traversable';

has 'service_path' => (
    is        => 'ro',
    isa       => 'Str',
    predicate => 'has_service_path'
);

has 'service_name' => (
    is      => 'ro',
    isa     => 'Str',
    lazy    => 1,
    default => sub {
        my $self = shift;
        ($self->has_service_path)
            || confess "Could not determine service name without service path";
        (split '/' => $self->service_path)[-1];
    }
);

has 'service_params' => (
    is        => 'ro',
    isa       => 'HashRef',
    predicate => 'has_service_params'
);

has 'service' => (
    is       => 'ro',
    does     => 'Bread::Board::Service | Bread::Board::Dependency',
    lazy     => 1,
    default  => sub {
        my $self = shift;
        ($self->has_service_path)
            || confess "Could not fetch service without service path";
        $self->fetch($self->service_path);
    },
    handles  => [ 'get', 'is_locked', 'lock', 'unlock' ]
);

__PACKAGE__->meta->make_immutable;

no Moose; 1;

__END__

=pod

=encoding UTF-8

=head1 NAME

Bread::Board::Dependency

=head1 VERSION

version 0.32

=head1 DESCRIPTION

=head1 METHODS

=over 4

=item B<get>

=item B<has_service_path>

=item B<is_locked>

=item B<lock>

=item B<service>

=item B<service_name>

=item B<service_path>

=item B<unlock>

=back

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
