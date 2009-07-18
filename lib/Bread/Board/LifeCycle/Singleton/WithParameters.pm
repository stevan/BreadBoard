package Bread::Board::LifeCycle::Singleton::WithParameters;
use Moose::Role;
use MooseX::AttributeHelpers;

with 'Bread::Board::LifeCycle';

our $VERSION   = '0.08';
our $AUTHORITY = 'cpan:STEVAN';

has 'instances' => (
    metaclass => 'Collection::Hash',
    is        => 'rw',
    isa       => 'HashRef',
    lazy      => 1,
    default   => sub { +{} },
    clearer   => 'flush_instances',
    provides  => {
        'exists' => 'has_instance_at_key',
        'get'    => 'get_instance_at_key',
        'set'    => 'set_instance_at_key',
    }
);

around 'get' => sub {
    my $next = shift;
    my $self = shift;
    my $key  = $self->generate_instance_key(@_);

    # return it if we got it ...
    return $self->get_instance_at_key($key)
        if $self->has_instance_at_key($key);

    # otherwise fetch it ...
    my $instance = $self->$next(@_);

    # if we get a copy, and our copy
    # has not already been set ...
    $self->set_instance_at_key($key => $instance)
        unless $self->has_instance_at_key($key);

    # return whatever we have ...
    return $self->get_instance_at_key($key);
};

sub generate_instance_key {
    my ($self, @args) = @_;
    return "$self" unless @args;
    return join "|" => sort map { "$_" } @args
}

no Moose::Role; 1;

__END__

=pod

=head1 NAME

Bread::Board::LifeCycle::Singleton::WithParameters

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

Copyright 2007-2009 by Infinity Interactive, Inc.

L<http://www.iinteractive.com>

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut