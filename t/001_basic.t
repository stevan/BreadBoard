#!/usr/bin/perl

use strict;
use warnings;

use Test::More no_plan => 1;
use Test::Moose;
use Test::Exception;

BEGIN {
    use_ok('Junkie::ConstructorInjection');
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
    name  => 'William',
    class => 'Addict',
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

my $i = $s->get(stash => Mexican::Black::Tar->new);

isa_ok($i, 'Addict');
isa_ok($i->needle, 'Needle');
is($i->spoon, 'Spoon!', '... got our literal service');
isa_ok($i->stash, 'Mexican::Black::Tar');

dies_ok {
    $s->get;
} '... you must supply the required parameters';

dies_ok {
    $s->get(stash => []);
} '... you must supply the required parameters as correct types';

dies_ok {
    $s->get(stash => Mexican::Black::Tar->new, foo => 10);
} '... you must supply the required parameters (and no more)';

{
    my $i2 = $s->get(stash => Mexican::Black::Tar->new);
    isnt($i, $i2, '... calling it again returns an new object');
}




