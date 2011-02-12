#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 14;
use Test::Moose;
use Test::Exception;

BEGIN {
    use_ok('Bread::Board');
}

my $c = container 'Application' => as {
    container 'Model' => as {
        service 'dsn' => '';
        service 'schema' => (
            class => 'My::App::Schema',
            dependencies => {
                dsn => depends_on('dsn'),
                user => depends_on('user'),
                pass => depends_on('pass')
            }
        );
    };
    container 'View' => as {
        service 'TT' => (
            class => 'My::App::View::TT',
            dependencies => {
                tt_include_path => depends_on('include_path')
            }
        )
    };
    container 'Controller';
};

my $model = $c->fetch('Application/Model');
isa_ok($model, 'Bread::Board::Container');


is($model->name, 'Model', '... got the right model');

{
    my $model2 = $c->fetch('/Application/Model');
    isa_ok($model2, 'Bread::Board::Container');

    is($model, $model2, '... they are the same thing');
}

my $dsn = $model->fetch('schema/dsn');
isa_ok($dsn, 'Bread::Board::Dependency');

is($dsn->service_path, 'dsn', '... got the right name');

{
    my $dsn2 = $c->fetch('/Application/Model/schema/dsn');
    isa_ok($dsn2, 'Bread::Board::Dependency');

    is($dsn, $dsn2, '... they are the same thing');
}

my $root = $model->fetch('..');
isa_ok($root, 'Bread::Board::Container');

is($root, $c, '... got the same container');

is($model, $model->fetch('../Application/Model'), '... navigated back to myself');
is($dsn, $model->fetch('../Model/schema/dsn'), '... navigated to dsn');

is($model, $dsn->fetch('../Model'), '... got the model from the dsn');
