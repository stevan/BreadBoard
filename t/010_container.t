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

my $c = Junkie::Container->new(name => '/');
isa_ok($c, 'Junkie::Container');

$c->add_sub_container( 
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
);

my $app = $c->get_sub_container('Application');
isa_ok($app, 'Junkie::Container');

is($app->name, 'Application', '... got the right container');

{
    my $controller = $app->get_sub_container('Controller');
    isa_ok($controller, 'Junkie::Container');

    is($controller->name, 'Controller', '... got the right container');
    is($controller->parent, $app, '... app is the parent of the controller');

    ok(!$controller->has_services, '... the controller has no services');
}
{
    my $view = $app->get_sub_container('View');
    isa_ok($view, 'Junkie::Container');

    is($view->name, 'View', '... got the right container');
    is($view->parent, $app, '... app is the parent of the view');

    ok($view->has_services, '... the veiw has services');
    
    my $service = $view->get_service('TT');
    does_ok($service, 'Junkie::Service');
    
    is($service->parent, $view, '... the parent of the service is the view');
}
{
    my $model = $app->get_sub_container('Model');
    isa_ok($model, 'Junkie::Container');

    is($model->name, 'Model', '... got the right container');
    is($model->parent, $app, '... app is the parent of the model');

    ok($model->has_services, '... the model has services');
    
    my $service = $model->get_service('schema');
    does_ok($service, 'Junkie::Service');
    
    is($service->parent, $model, '... the parent of the service is the model');    
}




