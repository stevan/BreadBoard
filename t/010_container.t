#!/usr/bin/perl

use strict;
use warnings;

use Test::More;
use Test::Moose;

use Bread::Board::Container;
use Bread::Board::ConstructorInjection;
use Bread::Board::Literal;

my $c = Bread::Board::Container->new(name => '/');
isa_ok($c, 'Bread::Board::Container');

$c->add_sub_container(
    Bread::Board::Container->new(
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
    )
);

my $app = $c->get_sub_container('Application');
isa_ok($app, 'Bread::Board::Container');

ok ! $app->can('find_type_constraint'), 'can not find_type_constraint';

is($app->name, 'Application', '... got the right container');

{
    my $controller = $app->get_sub_container('Controller');
    isa_ok($controller, 'Bread::Board::Container');

    is($controller->name, 'Controller', '... got the right container');
    is($controller->parent, $app, '... app is the parent of the controller');

    ok(!$controller->has_services, '... the controller has no services');
}
{
    my $view = $app->get_sub_container('View');
    isa_ok($view, 'Bread::Board::Container');

    is($view->name, 'View', '... got the right container');
    is($view->parent, $app, '... app is the parent of the view');

    ok($view->has_services, '... the veiw has services');

    my $service = $view->get_service('TT');
    does_ok($service, 'Bread::Board::Service');

    is($service->parent, $view, '... the parent of the service is the view');
}
{
    my $model = $app->get_sub_container('Model');
    isa_ok($model, 'Bread::Board::Container');

    is($model->name, 'Model', '... got the right container');
    is($model->parent, $app, '... app is the parent of the model');

    ok($model->has_services, '... the model has services');

    my $service = $model->get_service('schema');
    does_ok($service, 'Bread::Board::Service');

    is($service->parent, $model, '... the parent of the service is the model');
}

done_testing;
