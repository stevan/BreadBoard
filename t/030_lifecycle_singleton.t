#!/usr/bin/perl

use strict;
use warnings;

use Test::More;
use Test::Moose;

use Bread::Board::ConstructorInjection::Singleton;
use Bread::Board::Literal;

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

my $s = Bread::Board::ConstructorInjection::Singleton->new(
    name         => 'William',
    class        => 'Addict',
    dependencies => {
        needle => Bread::Board::ConstructorInjection->new(name => 'spike', class => 'Needle'),
        spoon  => Bread::Board::Literal->new(name => 'works', value => 'Spoon!'),
    },
    parameters => {
        stash => { isa => 'Mexican::Black::Tar' }
    }
);
isa_ok($s, 'Bread::Board::ConstructorInjection::Singleton');
isa_ok($s, 'Bread::Board::ConstructorInjection');
ok($s->does('Bread::Board::Service::WithClass'), '... does Bread::Board::Service::WithClass');
ok($s->does('Bread::Board::Service::WithDependencies'), '... does Bread::Board::Service::WithDependencies');
ok($s->does('Bread::Board::Service::WithParameters'), '... does Bread::Board::Service::WithParameters');
ok($s->does('Bread::Board::Service'), '... does Bread::Board::Service');
ok($s->does('Bread::Board::LifeCycle::Singleton'), '... does Bread::Board::LifeCycle::Singleton');

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
}

done_testing;
