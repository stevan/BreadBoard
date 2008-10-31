#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 16;
use Test::Moose;
use Test::Exception;

BEGIN {
    use_ok('Bread::Board::Container');
    use_ok('Bread::Board::ConstructorInjection');
    use_ok('Bread::Board::Literal');
}

my $c = Bread::Board::Container->new(
    name           => 'Application',
    sub_containers => [
        Bread::Board::Container->new(
            name     => 'Model',
            services => [
                Bread::Board::Literal->new(name => 'dsn',  value => ''),
                Bread::Board::ConstructorInjection->new(
                    name  => 'schema',
                    class => 'My::App::Schema',
                    dependencies => {
                        dsn  => Bread::Board::Dependency->new(service_path => '../dsn'),
                        user => Bread::Board::Literal->new(name => 'user', value => ''),
                        pass => Bread::Board::Literal->new(name => 'pass', value => ''),
                    },
                )
            ]
        ),
        Bread::Board::Container->new(
            name     => 'View',
            services => [
                Bread::Board::ConstructorInjection->new(
                    name  => 'TT',
                    class => 'My::App::View::TT',
                    dependencies => {
                        tt_include_path => Bread::Board::Literal->new(name => 'include_path',  value => []),
                    },
                )
            ]
         ),
         Bread::Board::Container->new(name => 'Controller'),
    ]
);

#use Bread::Board::Dumper;
#diag(Bread::Board::Dumper->new->dump($c));

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

is($dsn->service_path, '../dsn', '... got the right name');

{
    my $dsn2 = $c->fetch('/Application/Model/schema/dsn');
    isa_ok($dsn2, 'Bread::Board::Dependency');

    is($dsn, $dsn2, '... they are the same thing');
}

my $root = $model->fetch('../');
isa_ok($root, 'Bread::Board::Container');

is($root, $c, '... got the same container');

is($model, $model->fetch('../Application/Model'), '... navigated back to myself');
is($dsn, $model->fetch('../Model/schema/dsn'), '... navigated to dsn');

is($model, $dsn->fetch('../../'), '... got the model from the dsn');








