#!/usr/bin/perl

use strict;
use warnings;
use Bread::Board;

service 'logger' => (
    class        => 'FileLogger',
    #lifecycle    => 'Singleton',
    dependencies => {
        log_file => depends_on('log_file'),
    }
);