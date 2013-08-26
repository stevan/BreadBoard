package Bread::Board::Service;
use v5.16;
use warnings;
use mop;

use Try::Tiny;

use Carp 'confess';
use Scalar::Util 'blessed';

role WithDependencies with Bread::Board::Service {

    has $dependencies is lazy = {};

    method dependencies ($deps) {
        return $dependencies if not defined $deps;
        $_->parent($self) foreach values %$deps;
        $dependencies = $deps;
    }

    method add_dependency ($name, $dep) { $dependencies->{ $name } = $dep }
    method get_dependency ($name)       { $dependencies->{ $name }        }
    method has_dependency ($name)       { exists $dependencies->{ $name } }
    method has_dependencies             { scalar keys %$dependencies      }
    method get_all_dependencies {
        map { [ $_, $dependencies->{ $_ } ] } keys %$dependencies
    }

    method resolve_dependencies {
        my %deps;
        if ($self->has_dependencies) {
            foreach my $dep ($self->get_all_dependencies) {
                my ($key, $dependency) = @$dep;

                my $service = $dependency->service;

                # NOTE:
                # this is what checks for
                # circular dependencies
                if ($service->is_locked) {

                    confess "You cannot defer a parameterized service"
                        if $service->does('Bread::Board::Service::WithParameters')
                        && $service->has_parameters;

                    require Bread::Board::Service::Deferred;
                    $deps{$key} = Bread::Board::Service::Deferred->new(service => $service);
                }
                else {
                    # since we can't pass in parameters here,
                    # we return a deferred thunk and you can do
                    # with it what you will.
                    if (
                        $service->does('Bread::Board::Service::WithParameters')
                        &&
                        $service->has_required_parameters
                        &&
                        (not $service->has_parameter_defaults)
                        &&
                        (not $dependency->has_service_params)
                       ) {
                        require Bread::Board::Service::Deferred::Thunk;
                        $deps{$key} = Bread::Board::Service::Deferred::Thunk->new(
                            thunk => sub {
                                my %params = @_;
                                $service->lock;
                                return try { $service->get( %params ) }
                                   finally { $service->unlock }
                                     catch { die $_ }
                            }
                        );
                    }
                    else {
                        $service->lock;
                        try {
                            $deps{$key} = $dependency->has_service_params
                                ? $service->get( %{ $dependency->service_params })
                                : $service->get;
                        } finally {
                            $service->unlock
                        } catch {
                            die $_
                        };
                    }
                }
            }
        }
        return %deps;
    }
}

__END__

=pod

=head1 DESCRIPTION

=head1 METHODS

=over 4

=item B<init_params>

=item B<resolve_dependencies>

=item B<dependencies>

=item B<add_dependency>

=item B<get_dependency>

=item B<has_dependency>

=item B<has_dependencies>

=item B<get_all_dependencies>

=back

=head1 BUGS

All complex software has bugs lurking in it, and this module is no
exception. If you find a bug please either email me, or add the bug
to cpan-RT.

=cut
