#!/usr/bin/perl

use strict;
use warnings;

use Test::More no_plan => 1;
use Test::Moose;
use Test::Exception;

BEGIN {
    use_ok('Junkie::BlockInjection');
    use_ok('Junkie::SetterInjection');
    use_ok('Junkie::Literal');
}

{
    package Needle;
    use Moose;

    package Mexican::Black::Tar;
    use Moose;

    package Addict;
    use Moose;

    has 'needle' => (is => 'rw');
    has 'spoon'  => (is => 'rw');
    has 'stash'  => (is => 'rw');
}

my $s = Junkie::BlockInjection->new(
    name  => 'William',
    class => 'Addict',
    block => sub {
        my $s = shift;
        $s->class->new(%{ $s->params });
    },
    dependencies => {
        needle => Junkie::SetterInjection->new(name => 'spike', class => 'Needle'),
        spoon  => Junkie::Literal->new(name => 'works', value => 'Spoon!'),
    },
    parameters => {
        stash => { isa => 'Mexican::Black::Tar' }
    }
);
isa_ok($s, 'Junkie::BlockInjection');
does_ok($s, 'Junkie::Service::WithDependencies');
does_ok($s, 'Junkie::Service::WithParameters');
does_ok($s, 'Junkie::Service');

{
    my $i = $s->get(stash => Mexican::Black::Tar->new);

    isa_ok($i, 'Addict');
    isa_ok($i->needle, 'Needle');
    is($i->spoon, 'Spoon!', '... got our literal service');
    isa_ok($i->stash, 'Mexican::Black::Tar');

    {
        my $i2 = $s->get(stash => Mexican::Black::Tar->new);
        isnt($i, $i2, '... calling it again returns an new object');
    }
}

is($s->name, 'William', '... got the right name');
is($s->class, 'Addict', '... got the right class');

my $deps = $s->dependencies;
is_deeply([ sort keys %$deps ], [qw/needle spoon/], '... got the right dependency keys');

my $needle = $s->get_dependency('needle');
isa_ok($needle, 'Junkie::Dependency');
isa_ok($needle->service, 'Junkie::SetterInjection');

is($needle->service->name, 'spike', '... got the right name');
is($needle->service->class, 'Needle', '... got the right class');

my $spoon = $s->get_dependency('spoon');
isa_ok($spoon, 'Junkie::Dependency');
isa_ok($spoon->service, 'Junkie::Literal');

is($spoon->service->name, 'works', '... got the right name');
is($spoon->service->value, 'Spoon!', '... got the right literal value');

my $params = $s->parameters;
is_deeply([ sort keys %$params ], [qw/stash/], '... got the right paramter keys');
is_deeply($params->{stash}, { isa => 'Mexican::Black::Tar' }, '... got the right parameter spec');

## check some errors

dies_ok {
    $s->get;
} '... you must supply the required parameters';

dies_ok {
    $s->get(stash => []);
} '... you must supply the required parameters as correct types';

dies_ok {
    $s->get(stash => Mexican::Black::Tar->new, foo => 10);
} '... you must supply the required parameters (and no more)';





