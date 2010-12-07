package Bread::Board::BlockInjection;
use Moose;

our $VERSION   = '0.16';
our $AUTHORITY = 'cpan:STEVAN';

with 'Bread::Board::Service::WithDependencies',
     'Bread::Board::Service::WithParameters';

has 'block' => (
    is       => 'rw',
    isa      => 'CodeRef',
    required => 1,
);

has 'class' => (
    is        => 'rw',
    isa       => 'Str',
    predicate => 'has_class'
);


sub get {
    my $self = shift;
    Class::MOP::load_class($self->class) if $self->has_class;
    $self->block->($self)
}

__PACKAGE__->meta->make_immutable;

no Moose; 1;

__END__

=pod

=head1 NAME

Bread::Board::BlockInjection

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

Stevan Little E<lt>stevan@iinteractive.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright 2007-2010 by Infinity Interactive, Inc.

L<http://www.iinteractive.com>

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
