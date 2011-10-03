#!/usr/bin/perl

use strict;
use warnings;

use Test::More;
use Test::Moose;

use Bread::Board;

{
    package Serializer;
    use Moose;
    has 'format' => ( is => 'ro', isa => 'Str' );

    package Application;
    use Moose;
    has 'json' => ( is => 'ro', isa => 'Serializer' );
}

{
    my $c = container 'Test' => as {

        service 'Serializer' => (
            class      => 'Serializer',
            parameters => {
                'format' => { isa => 'Str' }
            }
        );

        service 'App' => (
            class        => 'Application',
            dependencies => {
                json => Bread::Board::Dependency->new(
                    service_path   => 'Serializer',
                    service_params => { 'format' => 'JSON' }
                )
            }
        );

    };

    my $app = $c->resolve( service => 'App' );
    isa_ok($app, 'Application');
    isa_ok($app->json, 'Serializer');
    is($app->json->format, 'JSON', '... got the right format');
}

{
    my $c = container 'Test' => as {

        service 'Serializer' => (
            class      => 'Serializer',
            parameters => {
                'format' => { isa => 'Str' }
            }
        );

        service 'App' => (
            class        => 'Application',
            dependencies => {
                json => { 'Serializer' => { 'format' => 'JSON' } }
            }
        );

    };

    my $app = $c->resolve( service => 'App' );
    isa_ok($app, 'Application');
    isa_ok($app->json, 'Serializer');
    is($app->json->format, 'JSON', '... got the right format');
}


done_testing;
