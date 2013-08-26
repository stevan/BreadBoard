#!/usr/bin/env perl
# -*- mode: cperl; -*-

use strict;
use warnings;
use Bread::Board;

container 'MyApp' => as {
    service 'name' => 'My Application!'; # need to test ::Literal :)

    service 'logger' => (
        #lifecycle => 'Singleton',
        class     => 'Logger',
    );

    container 'config' => as {
        service 'config_file' => (
            dependencies => [ depends_on('/name') ],
            #lifecycle    => 'Singleton',
            block        => sub {},
        );

        service 'template_dir' => (
            #lifecycle => 'Singleton',
            block     => sub {},
        );

        service 'dsn' => (
            #lifecycle    => 'Singleton',
            dependencies => [ depends_on('/logger'), depends_on('config_file') ],
            block        => sub {},
        );
    };

    service 'database' => (
        dependencies => [
            depends_on('logger'),
            depends_on('config/dsn'),
        ],
        block => sub { },
    );

    container 'templates' => as {
        service 'login' => (
            dependencies => [ depends_on('/config/template_dir') ],
            class        => 'Template',
            block        => sub {},
        );
    };

    container 'pages' => as {
        service 'login' => (
            class        => 'Page::Login',
            dependencies =>  [
                depends_on('/templates/login'),
                depends_on('/database'),
                depends_on('/logger'),
            ],
        );
    };
};
