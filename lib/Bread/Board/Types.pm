package Bread::Board::Types;
use Moose::Util::TypeConstraints;

use Bread::Board::Service;
use Bread::Board::Dependency;

enum 'Bread::Board::Service::LifeCycles' => qw[
    Null
    Singleton
];

## for Bread::Board::Container

subtype 'Bread::Board::Container::SubContainerList'
    => as 'HashRef[Bread::Board::Container]';

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
    => from 'HashRef[Bread::Board::Service | Bread::Board::Dependency]'
        => via { 
            +{ 
                map { 
                    $_ => ($_[0]->{$_}->isa('Bread::Board::Dependency')
                            ? $_[0]->{$_}
                            : Bread::Board::Dependency->new(service => $_[0]->{$_}))
                } keys %{$_[0]} 
            } 
        }
    => from 'ArrayRef[Bread::Board::Service | Bread::Board::Dependency]'
        => via {
            # auto-wire the dependencies with 
            # the service name if we get them 
            # as an array
            +{ 
                map { 
                    ($_->isa('Bread::Board::Dependency')
                        ? ($_->service_name => $_) 
                        : ($_->name         => Bread::Board::Dependency->new(service => $_)))
                } @{$_[0]} 
            }            
        };
    
## for Bread::Board::Service::WithParameters ...

subtype 'Bread::Board::Service::Parameters' => as 'HashRef';

coerce 'Bread::Board::Service::Parameters'
    => from 'ArrayRef'
        => via { +{ map { $_ => { optional => 0 } } @$_ } };
        
1;

__END__

=pod

=cut