#!/usr/bin/perl

use strict;
use warnings;

use Test::More;
use Test::Fatal;

use Bread::Board;

{
    package Model;
    use Moose;

    has [qw(dsn extra_args)] => (
        is       => 'ro',
        required => 1,
    );
}

{
    package UserStore;
    use Moose;

    has model => (
        is       => 'ro',
        isa      => 'Model',
        required => 1,
    );
}

my $c = container 'MyApp' => as {
    service model_dsn => 'foo:bar';

    service model => (
        class        => 'Model',
        #lifecycle    => 'Singleton',
        parameters   => {
            extra_args => {
                default => {
                    create   => 1,
                    user     => 'foo',
                    password => 'bar',
                },
            },
        },
        dependencies => {
            dsn => depends_on('model_dsn'),
        },
    );

    service user_store => (
        class        => 'UserStore',
        #lifecycle    => 'Singleton',
        dependencies => {
            model => depends_on('/model'),
        },
    );
};

my $store;

is(exception {
    $store = $c->fetch('/user_store')->get;
}, undef, '... deferred parameters that have defaults should pass through too');

is($store->model->dsn, 'foo:bar', '... got the right default values');

done_testing;
