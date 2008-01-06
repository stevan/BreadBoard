#!/usr/bin/perl

use strict;
use warnings;

use Test::More no_plan => 1;

BEGIN {
    use_ok('Bread::Board');

    use_ok('Bread::Board::Types');

    # roles
    use_ok('Bread::Board::Service');
    use_ok('Bread::Board::Service::WithClass');
    use_ok('Bread::Board::Service::WithDependencies');
    use_ok('Bread::Board::Service::WithParameters');

    # services
    use_ok('Bread::Board::ConstructorInjection');
    use_ok('Bread::Board::SetterInjection');
    use_ok('Bread::Board::BlockInjection');    
    use_ok('Bread::Board::Literal');
    
    use_ok('Bread::Board::Container');
    use_ok('Bread::Board::Dependency');
    
    use_ok('Bread::Board::Traversable');       
    
    use_ok('Bread::Board::LifeCycle::Singleton');       
}

