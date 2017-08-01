package Bread::Board::Service::WithConstructor;
our $AUTHORITY = 'cpan:STEVAN';
$Bread::Board::Service::WithConstructor::VERSION = '0.35';
use Moose::Role;

use Try::Tiny;

with 'Bread::Board::Service::WithClass';

has 'constructor_name' => (
    is       => 'rw',
    isa      => 'Str',
    lazy     => 1,
    builder  => '_build_constructor_name',
);

sub _build_constructor_name {
    my $self = shift;

    # using Class::MOP::class_of on a Moo 
    # object causes mayhem, so we take care of that
    # special case first. See GH#61
    try { $self->class->isa('Moo::Object') && 'new' }
    || try { Class::MOP::class_of($self->class)->constructor_name } 
    || 'new';
}

no Moose; 1;

__END__

=pod

=encoding UTF-8

=head1 NAME

Bread::Board::Service::WithConstructor

=head1 VERSION

version 0.35

=head1 DESCRIPTION

=head1 METHODS

=over 4

=item B<constructor_name>

=back

=head1 BUGS

All complex software has bugs lurking in it, and this module is no
exception. If you find a bug please either email me, or add the bug
to cpan-RT.

=head1 AUTHOR

Stevan Little <stevan@iinteractive.com>

=head1 BUGS

Please report any bugs or feature requests on the bugtracker website
https://github.com/stevan/BreadBoard/issues

When submitting a bug or request, please include a test-file or a
patch to an existing test-file that illustrates the bug or desired
feature.

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2017, 2016, 2015, 2014, 2013, 2011, 2009 by Infinity Interactive.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
