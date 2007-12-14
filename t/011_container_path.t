#!/usr/bin/perl

use strict;
use warnings;

use Test::More no_plan => 1;
use Test::Moose;
use Test::Exception;

BEGIN {
    use_ok('Junkie::Container');
    use_ok('Junkie::ConstructorInjection');
    use_ok('Junkie::Literal');
}

my $c = Junkie::Container->new(
    name => '/',
    sub_containers => [
        Junkie::Container->new(
            name           => 'Application',
            sub_containers => [
                Junkie::Container->new(
                    name     => 'Model',
                    services => [
                        Junkie::Literal->new(name => 'dsn',  value => ''),
                        Junkie::ConstructorInjection->new(
                            name  => 'schema',
                            class => 'My::App::Schema',
                            dependencies => {
                                dsn  => Junkie::Dependency->new(service_path => '../dsn'),
                                user => Junkie::Literal->new(name => 'user', value => ''),
                                pass => Junkie::Literal->new(name => 'pass', value => ''),
                            },
                        )
                    ]
                ),
                Junkie::Container->new(
                    name     => 'View',
                    services => [
                        Junkie::ConstructorInjection->new(
                            name  => 'TT',
                            class => 'My::App::View::TT',
                            dependencies => {
                                tt_include_path => Junkie::Literal->new(name => 'include_path',  value => []),
                            },
                        )
                    ]
                 ),
                 Junkie::Container->new(name => 'Controller'),
            ]
        )
    ]
);

my $model = $c->fetch('Application/Model');
isa_ok($model, 'Junkie::Container');

is($model->name, 'Model', '... got the right model');

{
    my $model2 = $c->fetch('/Application/Model');
    isa_ok($model2, 'Junkie::Container');

    is($model, $model2, '... they are the same thing');
}

my $dsn = $model->fetch('schema/dsn');
isa_ok($dsn, 'Junkie::Dependency');

is($dsn->service_path, '../dsn', '... got the right name');

{
    my $dsn2 = $c->fetch('/Application/Model/schema/dsn');
    isa_ok($dsn2, 'Junkie::Dependency');

    is($dsn, $dsn2, '... they are the same thing');
}

my $root = $model->fetch('../../');
isa_ok($root, 'Junkie::Container');

is($root, $c, '... got the same container');

is($model, $model->fetch('../../Application/Model'), '... navigated back to myself');
is($dsn, $model->fetch('../Model/schema/dsn'), '... navigated to dsn');

is($model, $dsn->fetch('../../'), '... got the model from the dsn');








