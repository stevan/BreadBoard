package Bread::Board::BlockInjection;
BEGIN {
  $Bread::Board::BlockInjection::AUTHORITY = 'cpan:STEVAN';
}
$Bread::Board::BlockInjection::VERSION = '0.32';
use Moose;

with 'Bread::Board::Service::WithParameters',
     'Bread::Board::Service::WithDependencies',
     'Bread::Board::Service::WithClass';

has 'block' => (
    is       => 'rw',
    isa      => 'CodeRef',
    required => 1,
);


sub get {
    my $self = shift;
    $self->block->($self)
}

__PACKAGE__->meta->make_immutable;

no Moose; 1;

__END__

=pod

=encoding UTF-8

=head1 NAME

Bread::Board::BlockInjection

=head1 VERSION

version 0.32

=head1 DESCRIPTION

=head1 METHODS

=over 4

=item B<block>

=item B<class>

=item B<has_class>

=item B<get>

=item B<meta>

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
