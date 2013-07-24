package Bread::Board::Types;
use Moose::Util::TypeConstraints;

use Scalar::Util qw(blessed);

use Bread::Board::Service;
use Bread::Board::Dependency;

enum 'Bread::Board::Service::LifeCycles' => qw[
    Null
    Singleton
];

## for Bread::Board::Container

class_type 'Bread::Board::Container';
class_type 'Bread::Board::Container::Parameterized';

subtype 'Bread::Board::Container::SubContainerList'
    => as 'HashRef[Bread::Board::Container|Bread::Board::Container::Parameterized]';

coerce 'Bread::Board::Container::SubContainerList'
    => from 'ArrayRef[Bread::Board::Container]'
        => via { +{ map { $_->name => $_ } @$_ } };

subtype 'Bread::Board::Container::ServiceList'
    => as 'HashRef[Bread::Board::Service]';

coerce 'Bread::Board::Container::ServiceList'
    => from 'ArrayRef[Bread::Board::Service]'
        => via { +{ map { $_->name => $_ } @$_ } };

## for Bread::Board::Service::WithDependencies ...

subtype 'Bread::Board::Service::Dependencies'
    => as 'HashRef[Bread::Board::Dependency]';

coerce 'Bread::Board::Service::Dependencies'
    => from 'HashRef[Bread::Board::Service | Bread::Board::Dependency | Str | HashRef]'
        => via {
            +{
                map {

                    my $dep = $_[0]->{$_};
                    if (!blessed($dep)) {
                        if (ref $dep) {
                            my ($service_path)   = keys %$dep;
                            my ($service_params) = values %$dep;
                            $dep = Bread::Board::Dependency->new(
                                service_path   => $service_path,
                                service_params => $service_params
                            );
                        }
                        else {
                            $dep = Bread::Board::Dependency->new(service_path => $dep);
                        }
                    }
                    ($_ => ($dep->isa('Bread::Board::Dependency')
                            ? $dep
                            : Bread::Board::Dependency->new(service => $dep)))
                } keys %{$_[0]}
            }
        }
    => from 'ArrayRef[Bread::Board::Service | Bread::Board::Dependency | Str | HashRef]'
        => via {
            # auto-wire the dependencies with
            # the service name if we get them
            # as an array
            +{
                map {
                    my $dep = $_;
                    if (!blessed($dep)) {
                        if (ref $dep) {
                            my ($service_path)   = keys %$dep;
                            my ($service_params) = values %$dep;
                            $dep = Bread::Board::Dependency->new(
                                service_path   => $service_path,
                                service_params => $service_params
                            );
                        }
                        else {
                            $dep = Bread::Board::Dependency->new(service_path => $dep);
                        }
                    }
                    ($dep->isa('Bread::Board::Dependency')
                        ? ($dep->service_name => $dep)
                        : ($dep->name         => Bread::Board::Dependency->new(service => $dep)))
                } @{$_[0]}
            }
        };

## for Bread::Board::Service::WithParameters ...

subtype 'Bread::Board::Service::Parameters' => as 'HashRef';

coerce 'Bread::Board::Service::Parameters'
    => from 'ArrayRef'
        => via { +{ map { $_ => { optional => 0 } } @$_ } };

no Moose::Util::TypeConstraints; 1;

__END__

=pod

=head1 DESCRIPTION

=head1 BUGS

All complex software has bugs lurking in it, and this module is no
exception. If you find a bug please either email me, or add the bug
to cpan-RT.

=cut
