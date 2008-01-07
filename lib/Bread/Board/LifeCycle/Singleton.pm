package Bread::Board::LifeCycle::Singleton;
use Moose::Role;

with 'Bread::Board::LifeCycle';

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

has 'instance' => (
    is        => 'rw', 
    isa       => 'Any',
    predicate => 'has_instance',
    clearer   => 'flush_instance'
);

around 'get' => sub {
    my $next = shift;
    my $self = shift;
    
    # return it if we got it ...
    return $self->instance if $self->has_instance;
    
    # otherwise fetch it ...
    my $instance = $self->$next(@_);
    
    # if we get a copy, and our copy 
    # has not already been set ...
    $self->instance($instance) unless $self->has_instance;
    
    # return whatever we have ...
    return $self->instance;
};

1;

__END__

=pod

=head1 NAME

Bread::Board::LifeCycle::Singleton

=head1 DESCRIPTION

=head1 METHODS

=over 4

=item B<get>

=item B<instance>

=item B<has_instance>

=item B<flush_instance>

=back

=head1 BUGS

All complex software has bugs lurking in it, and this module is no
exception. If you find a bug please either email me, or add the bug
to cpan-RT.

=head1 AUTHOR

Stevan Little E<lt>stevan@iinteractive.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright 2007-2008 by Infinity Interactive, Inc.

L<http://www.iinteractive.com>

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut