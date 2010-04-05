package Bread::Board::Container::Parameterized;
use Moose;

use Bread::Board::Container;

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

has 'name' => (
    is       => 'rw',
    isa      => 'Str',
    required => 1
);

has 'param_names' => (
    is       => 'ro',
    isa      => 'ArrayRef',
    required => 1,
);

has 'container' => (
    is      => 'ro',
    isa     => 'Bread::Board::Container',
    lazy    => 1,
    default => sub {
        my $self = shift;
        Bread::Board::Container->new( name => $self->name )
    },
    handles => [qw[
        add_service
        get_service
        has_service
        get_service_list
        has_services

        add_sub_container
        get_sub_container
        has_sub_container
        get_sub_container_list
        has_sub_containers

        parent
        detach_from_parent
        has_parent

        get_root_container
    ]]
);

sub create {
    my ($self, @params) = @_;

    my $clone = $self->container->clone( name => join "|" => $self->name, @params );

    my @param_name = @{ $self->param_names };

    foreach my $param ( @params ) {
        my $cloned_param = $param->clone( name => shift @param_name );
        $clone->add_sub_container( $cloned_param );
    }

    $clone;
}

__PACKAGE__->meta->make_immutable;

no Moose; 1;

__END__

=pod

=head1 NAME

Bread::Board::Container::Parameterized - A Moosey solution to this problem

=head1 SYNOPSIS

  use Bread::Board::Container::Parameterized;

=head1 DESCRIPTION

=head1 METHODS

=over 4

=item B<>

=back

=head1 BUGS

All complex software has bugs lurking in it, and this module is no
exception. If you find a bug please either email me, or add the bug
to cpan-RT.

=head1 AUTHOR

Stevan Little E<lt>stevan.little@iinteractive.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright 2010 Infinity Interactive, Inc.

L<http://www.iinteractive.com>

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
