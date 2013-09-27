package Bread::Board;
use v5.16;
use warnings;
use mop;

use Carp 'confess';
use Scalar::Util 'blessed';

use Bread::Board::Util qw(coerce_key_from_array_to_name_map);

use MooseX::Params::Validate qw(validated_hash);

class Container with Bread::Board::Traversable {

    has $!name           is rw   = die '$!name is required';
    has $!services       is lazy = {};
    has $!sub_containers is lazy = {};

    method new ($class: %args) {
        coerce_key_from_array_to_name_map( \%args, 'services' );
        coerce_key_from_array_to_name_map( \%args, 'sub_containers' );
        $class->next::method( %args );
    }

    submethod BUILD {
        $_->parent($self) foreach values %{$!services};
        $_->parent($self) foreach values %{$!sub_containers};
    }

    method services ($services) {
        if ($services) {
            $_->parent($self) foreach values %$services;
            $!services = $services;
        }
        $!services;
    }

    method get_service ($name) { $!services->{ $name }        }
    method has_service ($name) { exists $!services->{ $name } }
    method get_service_list    { keys %{$!services}             }
    method has_services        { scalar keys %{$!services}      }

    method sub_containers ($sub_containers) {
        if ($sub_containers) {
            $_->parent($self) foreach values %$sub_containers;
            $!sub_containers = $sub_containers;
        }
        $!sub_containers;
    }

    method get_sub_container ($name) { $!sub_containers->{ $name }        }
    method has_sub_container ($name) { exists $!sub_containers->{ $name } }
    method get_sub_container_list    { keys %{$!sub_containers}             }
    method has_sub_containers        { scalar keys %{$!sub_containers}      }

    method add_service ($service) {
        (blessed $service && $service->does('Bread::Board::Service'))
            || confess "You must pass in a Bread::Board::Service instance, not $service";
        $service->parent($self);
        $!services->{$service->name} = $service;
    }

    method add_sub_container ($container) {
        (blessed $container && $container->isa('Bread::Board::Container'))
            || confess "You must pass in a Bread::Board::Container instance, not $container";
        $container->parent($self);
        $!sub_containers->{$container->name} = $container;
    }

    method resolve {
        my (%params) = validated_hash(\@_,
            service    => { isa => 'Str',     optional => 1 },
            parameters => { isa => 'HashRef', optional => 1 },
        );

        my %parameters = exists $params{'parameters'}
            ? %{ $params{'parameters'} }
            : ();

        if (my $service_path = $params{'service'}) {
            my $service = $self->fetch( $service_path );
            # NOTE:
            # we might want to allow Bread::Board::Service::Deferred::Thunk
            # objects as well, but I am not sure that is a valid use case
            # for this, so for now we just don't go there.
            # - SL
            (blessed $service && $service->does('Bread::Board::Service'))
                || confess "You can only resolve services, "
                         . (defined $service ? $service : 'undef')
                         . " is not a Bread::Board::Service";
            return $service->get( %parameters );
        }
        else {
            confess "Cannot call resolve without telling it what to resolve.";
        }

    }

}

1;

__END__

=pod

=head1 DESCRIPTION

=head1 METHODS

=over 4

=item B<add_service>

=item B<add_sub_container>

=item B<get_service>

=item B<get_service_list>

=item B<get_sub_container>

=item B<get_sub_container_list>

=item B<has_service>

=item B<has_services>

=item B<has_sub_container>

=item B<has_sub_containers>

=item B<name>

=item B<services>

=item B<sub_containers>

=item B<fetch ( $service_name )>

=item B<resolve ( ?service => $service_name, ?type => $type, ?parameters => { ... } )>

=item B<add_type_mapping_for ( $type_name, $service )>

=item B<get_type_mapping_for ( $type_name )>

=item B<has_type_mapping_for ( $type_name )>

=back

=head1 BUGS

All complex software has bugs lurking in it, and this module is no
exception. If you find a bug please either email me, or add the bug
to cpan-RT.

=cut





