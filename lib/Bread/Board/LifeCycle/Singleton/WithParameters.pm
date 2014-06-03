package Bread::Board::LifeCycle::Singleton::WithParameters;
BEGIN {
  $Bread::Board::LifeCycle::Singleton::WithParameters::AUTHORITY = 'cpan:STEVAN';
}
$Bread::Board::LifeCycle::Singleton::WithParameters::VERSION = '0.32';
use Moose::Role;

with 'Bread::Board::LifeCycle';

has 'instances' => (
    traits    => [ 'Hash', 'NoClone' ],
    is        => 'rw',
    isa       => 'HashRef',
    lazy      => 1,
    default   => sub { +{} },
    clearer   => 'flush_instances',
    handles  => {
        'has_instance_at_key' => 'exists',
        'get_instance_at_key' => 'get',
        'set_instance_at_key' => 'set',
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

=encoding UTF-8

=head1 NAME

Bread::Board::LifeCycle::Singleton::WithParameters

=head1 VERSION

version 0.32

=head1 DESCRIPTION

=head1 METHODS

=over 4

=item B<get>

=item B<instance>

=item B<has_instance>

=item B<flush_instance>

=item B<generate_instance_key>

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
