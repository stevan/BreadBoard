package Junkie::Types;
use Moose::Util::TypeConstraints;

## load the Junkie::Service type 
## that is created in this module
use Junkie::Service;

## for Junkie::Service::WithDependencies ...

subtype 'Junkie::Service::Dependencies' 
    => as 'HashRef[Junkie::Service]';
    
## for Junkie::Service::WithParameters ...

subtype 'Junkie::Service::Parameters' => as 'HashRef';

coerce 'Junkie::Service::Parameters'
    => from 'ArrayRef'
        => via { +{ map { $_ => { optional => 0 } } @$_ } };
        
1;

__END__

=pod

=cut