package Bread::Board::Service;
use Moose::Role;

our $VERSION   = '0.18';
our $AUTHORITY = 'cpan:STEVAN';

with 'Bread::Board::Traversable';

has 'name' => (
    is       => 'rw',
    isa      => 'Str',
    required => 1
);

has 'params' => (
    traits   => [ 'Hash' ],
    is       => 'rw',
    isa      => 'HashRef',
    lazy     => 1,
    builder  => 'init_params',
    clearer  => 'clear_params',
    handles  => {
        get_param      => 'get',
        get_param_keys => 'keys',
        _clear_param   => 'delete',
        _set_param     => 'set',
    }
);

has 'is_locked' => (
    is      => 'rw',
    isa     => 'Bool',
    default => sub { 0 }
);

has 'lifecycle' => (
    is      => 'rw',
    isa     => 'Str',
    trigger => sub {
        my ($self, $lifecycle) = @_;
        if ($self->does('Bread::Board::LifeCycle')) {
            bless $self => (Class::MOP::class_of($self)->superclasses)[0];
            return if $lifecycle eq 'Null';
        }
        Class::MOP::class_of("Bread::Board::LifeCycle::${lifecycle}")->apply($self);
    }
);

sub init_params { +{} }
sub param {
    my $self = shift;
    return $self->get_param_keys     if scalar @_ == 0;
    return $self->get_param( $_[0] ) if scalar @_ == 1;
    ((scalar @_ % 2) == 0)
        || confess "parameter assignment must be an even numbered list";
    my %new = @_;
    while (my ($key, $value) = each %new) {
        $self->set_param( $key => $value );
    }
    return;
}

requires 'get';

sub lock   { (shift)->is_locked(1) }
sub unlock { (shift)->is_locked(0) }

no Moose::Role; 1;

__END__

=pod

=head1 NAME

Bread::Board::Service

=head1 DESCRIPTION

=head1 METHODS

=over 4

=item B<name>

=item B<is_locked>

=item B<lock>

=item B<unlock>

=item B<lifecycle>

=item B<get>

=back

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
