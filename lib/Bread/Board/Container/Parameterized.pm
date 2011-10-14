package Bread::Board::Container::Parameterized;
use Moose;
# ABSTRACT: A parameterized container

use Bread::Board::Container;

with 'Bread::Board::Traversable';

has 'name' => (
    is       => 'rw',
    isa      => 'Str',
    required => 1
);

has 'allowed_parameter_names' => (
    is       => 'ro',
    isa      => 'ArrayRef',
    required => 1,
);

has 'container' => (
    is      => 'ro',
    isa     => 'Bread::Board::Container',
    lazy    => 1,
    builder => '_build_container',
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
    ]]
);

sub _build_container {
    my $self = shift;
    Bread::Board::Container->new( name => $self->name )
}

sub fetch   { die "Cannot fetch from a parameterized container";   }
sub resolve { die "Cannot resolve from a parameterized container"; }

sub create {
    my ($self, %params) = @_;

    my @allowed_names = sort @{ $self->allowed_parameter_names };
    my @given_names   = sort keys %params;

    (scalar @allowed_names == scalar @given_names)
        || confess "You did not pass the correct number of parameters";

    ((join "" => @allowed_names) eq (join "" => @given_names))
        || confess "Incorrect parameter list, got: ("
                 . (join "" => @given_names)
                 . ") expected: ("
                 . (join "" => @allowed_names)
                 . ")";


    my $clone = $self->container->clone(
        name => ($self->container->name eq $self->name
                    ? join "|" => $self->name, @given_names
                    : $self->container->name)
    );

    foreach my $key ( @given_names ) {
        $clone->add_sub_container(
            $params{ $key }->clone( name => $key )
        );
    }

    $clone;
}

__PACKAGE__->meta->make_immutable;

no Moose; 1;

__END__

=pod

=head1 DESCRIPTION

=head1 ATTRIBUTES

=over 4

=item B<name>

=item B<allowed_parameter_names>

=item B<container>

=back

=head1 METHODS

=over 4

=item B<create ( %params )>

=item B<fetch>
=item B<resolve>

These two methods die, they are not appropriate, but are here for
completeness.

=back

=head1 BUGS

All complex software has bugs lurking in it, and this module is no
exception. If you find a bug please either email me, or add the bug
to cpan-RT.

=cut
