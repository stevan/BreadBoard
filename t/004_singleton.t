#!/usr/bin/perl

use strict;
use warnings;

use Test::More no_plan => 1;
use Test::Moose;
use Test::Exception;

BEGIN {
    use_ok('Junkie::ConstructorInjection');    
    use_ok('Junkie::LifeCycle::Singleton');   
    use_ok('Junkie::Literal');        
}

{
    package Needle;
    use Moose;
    
    package Mexican::Black::Tar;
    use Moose;
    
    package Addict;
    use Moose;
    
    has 'needle' => (is => 'ro');
    has 'spoon'  => (is => 'ro');
    has 'stash'  => (is => 'ro');        
}

my $s = Junkie::ConstructorInjection->new(
    lifecycle    => 'Singleton',    
    name         => 'William',
    class        => 'Addict',
    dependencies => {
        needle => Junkie::ConstructorInjection->new(name => 'spike', class => 'Needle'),
        spoon  => Junkie::Literal->new(name => 'works', value => 'Spoon!'),        
    },
    parameters => {
        stash => { isa => 'Mexican::Black::Tar' }
    }
);
isa_ok($s, 'Junkie::ConstructorInjection');
does_ok($s, 'Junkie::Service::WithClass');
does_ok($s, 'Junkie::Service::WithDependencies');
does_ok($s, 'Junkie::Service::WithParameters');
does_ok($s, 'Junkie::Service');
does_ok($s, 'Junkie::LifeCycle::Singleton');
is($s->lifecycle, 'Singleton', '... got the right lifecycle');

ok(!$s->has_instance, '... we dont have an instance yet');

my $i = $s->get(stash => Mexican::Black::Tar->new);

ok($s->has_instance, '... we do have an instance now');

isa_ok($i, 'Addict');
isa_ok($i->needle, 'Needle');
is($i->spoon, 'Spoon!', '... got our literal service');
isa_ok($i->stash, 'Mexican::Black::Tar');

{
    my $i2 = $s->get(stash => Mexican::Black::Tar->new);    
    is($i, $i2, '... calling it again returns the same object');
}

$s->flush_instance;

{
    my $i2 = $s->get(stash => Mexican::Black::Tar->new);    
    isnt($i, $i2, '... calling it again returns an new object');
    
    {
        my $i2a = $s->get(stash => Mexican::Black::Tar->new);    
        is($i2, $i2a, '... calling it again returns the same object');
    }   
    
    $s->lifecycle('Null');
    ok(!$s->can('flush_instance'), '... we can no longer call flush_instance');    
    ok(!$s->can('instance'), '... we can no longer call instance');        
    ok(!$s->can('has_instance'), '... we can no longer call has_instance');    
    
    is($s->lifecycle, 'Null', '... got the right lifecycle');            
    
    {
        my $i2a = $s->get(stash => Mexican::Black::Tar->new);    
        isnt($i2, $i2a, '... calling it again returns a new object');
        
        {
            my $i2a1 = $s->get(stash => Mexican::Black::Tar->new);    
            isnt($i2, $i2a1, '... calling it again returns a new object as before');
            isnt($i2a, $i2a1, '... calling it again returns a new object');            
        }        
    }    
}

$s->lifecycle('Singleton');
ok($s->can('flush_instance'), '... we can no longer call flush_instance');    
ok($s->can('instance'), '... we can no longer call instance');        
ok($s->can('has_instance'), '... we can no longer call has_instance');

is($s->lifecycle, 'Singleton', '... got the right lifecycle');

{
    my $i2 = $s->get(stash => Mexican::Black::Tar->new);    
    isnt($i, $i2, '... calling it again returns the same object');
    
    {
        my $i2a = $s->get(stash => Mexican::Black::Tar->new);    
        is($i2, $i2a, '... calling it again returns the same object');
    }    
}

