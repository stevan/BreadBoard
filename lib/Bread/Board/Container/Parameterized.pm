package Bread::Board::Container::Parameterized;
use Moose;
use Moose::Util 'find_meta';
use Bread::Board::Container::FromParameterized;
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

    my $from_parameterized_meta = find_meta('Bread::Board::Container::FromParameterized');
    $clone = $from_parameterized_meta->rebless_instance($clone);

    if ($self->has_parent) {
        my $cloned_parent = $self->parent->clone;

        $cloned_parent->sub_containers({
            %{ $cloned_parent->sub_containers },
            $self->name => $clone,
        });

        $clone->parent($cloned_parent);
    }

    foreach my $key ( @given_names ) {
        $clone->add_sub_container(
            $params{ $key }->clone( name => $key )
        );
    }

    $clone;
}

__PACKAGE__->meta->make_immutable;

no Moose; no Moose::Util; 1;

__END__

=pod

=head1 DESCRIPTION

This class implements a sort of container factory for L<Bread::Board>:
a parameterized container is a, in practice, a function from a set of
parameters (which must be containers) to an actual container. See
L<Bread::Board::Manual::Example::FormSensible> for an example.

=head1 ATTRIBUTES

=over 4

=item B<name>

Read/write string, required. Every container needs a name, by which it
can be referenced when L<fetching it|Bread::Board::Traversable/fetch>.

=item B<allowed_parameter_names>

Read-only arrayref of strings, required. These are the names of the
containers that must be passed to L<< C<create>|create ( %params ) >>
to get an actual container out of this parameterized object.

=item B<container>

This attribute holds the "prototype" container. Services inside it can
depend on service paths that include the container names given in
L</allowed_parameter_names>.

=back

=head1 METHODS

=over 4

=item B<add_service>

=item B<get_service>

=item B<has_service>

=item B<get_service_list>

=item B<has_services>

=item B<add_sub_container>

=item B<get_sub_container>

=item B<has_sub_container>

=item B<get_sub_container_list>

=item B<has_sub_containers>

All these methods are delegated to the "prototype" L</container>, so
that this object can be defined as if it were a normal container.

=item B<create ( %params )>

After checking that the keys of C<%params> are exactly the same
strings that are present in L</allowed_parameter_names>, this method
clones the prototype L</container>, adds the C<%params> to the clone
as sub-containers, and returns the clone.

If this was not a top-level container, the parent is also cloned, and
the container clone is added to the parent clone.

Please note that the container returned by this method does I<not>
have the same name as the parameterized container, and that calling
this method with different parameter values will return different
containers, but all with the same name. It's probably a bad idea to
instantiate a non-top-level parameterized container more than once.

=item B<fetch>

=item B<resolve>

These two methods die, since services in a parameterized container
won't usually resolve, and attempting to do so is almost always a
mistake.

=back

=head1 BUGS

All complex software has bugs lurking in it, and this module is no
exception. If you find a bug please either email me, or add the bug
to cpan-RT.

=cut
