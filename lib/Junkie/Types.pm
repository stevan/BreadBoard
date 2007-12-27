package Junkie::Types;
use Moose::Util::TypeConstraints;

use Junkie::Service;
use Junkie::Dependency;

enum 'Junkie::Service::LifeCycles' => qw[
    Null
    Singleton
];

## for Junkie::Container

subtype 'Junkie::Container::SubContainerList'
    => as 'HashRef[Junkie::Container]';

coerce 'Junkie::Container::SubContainerList'
    => from 'ArrayRef[Junkie::Container]'
        => via { +{ map { $_->name => $_ } @$_ } };
        
subtype 'Junkie::Container::ServiceList'
    => as 'HashRef[Junkie::Service]';

coerce 'Junkie::Container::ServiceList'
    => from 'ArrayRef[Junkie::Service]'
        => via { +{ map { $_->name => $_ } @$_ } };        

## for Junkie::Service::WithDependencies ...

subtype 'Junkie::Service::Dependencies' 
    => as 'HashRef[Junkie::Dependency]';

coerce 'Junkie::Service::Dependencies'
    => from 'HashRef[Junkie::Service | Junkie::Dependency]'
        => via { 
            +{ 
                map { 
                    $_ => ($_[0]->{$_}->isa('Junkie::Dependency')
                            ? $_[0]->{$_}
                            : Junkie::Dependency->new(service => $_[0]->{$_}))
                } keys %{$_[0]} 
            } 
        }
    => from 'ArrayRef[Junkie::Service | Junkie::Dependency]'
        => via {
            # auto-wire the dependencies with 
            # the service name if we get them 
            # as an array
            +{ 
                map { 
                    ($_->isa('Junkie::Dependency')
                        ? ($_->service_name => $_) 
                        : ($_->name         => Junkie::Dependency->new(service => $_)))
                } @{$_[0]} 
            }            
        };
    
## for Junkie::Service::WithParameters ...

subtype 'Junkie::Service::Parameters' => as 'HashRef';

coerce 'Junkie::Service::Parameters'
    => from 'ArrayRef'
        => via { +{ map { $_ => { optional => 0 } } @$_ } };
        
1;

__END__

=pod

=cut