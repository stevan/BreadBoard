package Bread::Board::Service::WithDependencies;
use Moose::Role;

use Try::Tiny;

use Bread::Board::Types;
use Bread::Board::Service::Deferred;
use Bread::Board::Service::Deferred::Thunk;

with 'Bread::Board::Service';

has 'dependencies' => (
    traits    => [ 'Hash', 'Clone' ],
    is        => 'rw',
    isa       => 'Bread::Board::Service::Dependencies',
    lazy      => 1,
    coerce    => 1,
    default   => sub { +{} },
    trigger   => sub {
        my $self = shift;
        foreach my $d (values %{$self->dependencies}) {
            if (ref($d) eq 'ARRAY') {
                $_->parent($self) for @$d;
            }
            else {
                $d->parent($self);
            }
        }
    },
    handles  => {
        'add_dependency'       => 'set',
        'get_dependency'       => 'get',
        'has_dependency'       => 'exists',
        'has_dependencies'     => 'count',
        'get_all_dependencies' => 'kv',
    }
);

around 'init_params' => sub {
    my $next = shift;
    my $self = shift;
    +{ %{ $self->$next() }, $self->resolve_dependencies }
};

after 'get' => sub { (shift)->clear_params };

sub _resolve_one_dependency {
    my ($self, $dependency) = @_;
            my $service = $dependency->service;

            # NOTE:
            # this is what checks for
            # circular dependencies
            if ($service->is_locked) {

                confess "You cannot defer a parameterized service"
                    if $service->does('Bread::Board::Service::WithParameters')
                    && $service->has_parameters;

                return Bread::Board::Service::Deferred->new(service => $service);
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
                    return Bread::Board::Service::Deferred::Thunk->new(
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
                    my $ret;
                    try {
                        $ret = $dependency->has_service_params
                            ? $service->get( %{ $dependency->service_params })
                            : $service->get;
                    } finally {
                        $service->unlock
                    } catch {
                        die $_
                    };
                    return $ret;
                }
            }
}

sub resolve_dependencies {
    my $self = shift;
    my %deps;
    if ($self->has_dependencies) {
        foreach my $dep ($self->get_all_dependencies) {
            my ($key, $dependency) = @$dep;

            if (ref($dependency) eq 'ARRAY') {
                $deps{$key} = [
                    map {$self->_resolve_one_dependency($_)}
                        @$dependency
                    ];
            }
            else {
                $deps{$key} = $self->_resolve_one_dependency($dependency);
            }

        }
    }
    return %deps;
}

no Moose::Role; 1;

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
