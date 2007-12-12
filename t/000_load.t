#!/usr/bin/perl

use strict;
use warnings;

use Test::More no_plan => 1;

BEGIN {
    use_ok('Junkie');

    use_ok('Junkie::Types');

    # roles
    use_ok('Junkie::Service');
    use_ok('Junkie::Service::WithClass');
    use_ok('Junkie::Service::WithDependencies');
    use_ok('Junkie::Service::WithParameters');

    # services
    use_ok('Junkie::ConstructorInjection');
    use_ok('Junkie::SetterInjection');
    use_ok('Junkie::BlockInjection');    
    use_ok('Junkie::Literal');  
}