#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 10;
use Test::Fatal;

use Bread::Board;

is(exception { container 'MyApp' => sub { "dummy" } }, undef);
is(exception { as { "Dummy" } }, undef);
is(exception {
    container 'MyApp' => as { service 'service1' => 'foo' };
}, undef);
is(exception {
    container 'MyApp' => as {
        service 'service1' => 'foo';
        service 'service2' => (
            block => sub { "dummy" },
            dependencies => wire_names 'service1'
        );
    }
}, undef);
is(exception {
    container 'MyApp' => as {
        service 'service1' => 'foo';
        service 'service2' => (
            block => sub { "dummy" },
            dependencies => {
                service1 => depends_on 'service1'
            }
        );
    }
}, undef);

no Bread::Board;

like(exception { container() },
     qr/^Undefined subroutine &main::container called/);
like(exception { as() },
     qr/^Undefined subroutine &main::as called/);
like(exception { service() },
     qr/^Undefined subroutine &main::service called/);
like(exception { depends_on() },
     qr/^Undefined subroutine &main::depends_on called/);
like(exception { wire_names() },
     qr/^Undefined subroutine &main::wire_names called/);
