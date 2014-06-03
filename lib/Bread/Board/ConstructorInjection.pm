package Bread::Board::ConstructorInjection;
BEGIN {
  $Bread::Board::ConstructorInjection::AUTHORITY = 'cpan:STEVAN';
}
$Bread::Board::ConstructorInjection::VERSION = '0.32';
use Moose;

use Try::Tiny;

use Bread::Board::Types;

with 'Bread::Board::Service::WithClass',
     'Bread::Board::Service::WithParameters',
     'Bread::Board::Service::WithDependencies';

has 'constructor_name' => (
    is       => 'rw',
    isa      => 'Str',
    lazy     => 1,
    builder  => '_build_constructor_name',
);

has '+class' => (required => 1);

sub _build_constructor_name {
    my $self = shift;

    try { Class::MOP::class_of($self->class)->constructor_name } || 'new';
}

sub get {
    my $self = shift;

    my $constructor = $self->constructor_name;
    $self->class->$constructor( %{ $self->params } );
}

__PACKAGE__->meta->make_immutable;

no Moose; 1;

__END__

=pod

=encoding UTF-8

=head1 NAME

Bread::Board::ConstructorInjection

=head1 VERSION

version 0.32

=head1 DESCRIPTION

=head1 METHODS

=over 4

=item B<get>

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
