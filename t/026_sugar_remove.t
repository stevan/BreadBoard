#!/usr/bin/perl

use strict;
use warnings;

use Test::More;
use Test::Fatal;

use Bread::Board;

is(exception { container 'MyApp' => sub { "dummy" } }, undef, 'container sugar does not throw exception');
is(exception { as { "Dummy" } }, undef, 'as sugar does not throw exception');
is(exception {
    container 'MyApp' => as { service 'service1' => 'foo' };
}, undef, 'as service sugar does not throw exception');
is(exception {
    container 'MyApp' => as {
        service 'service1' => 'foo';
        service 'service2' => (
            block => sub { "dummy" },
            dependencies => wire_names 'service1'
        );
    }
}, undef, 'container, service and wire_names sugar does not throw exception');
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
}, undef, 'container, service, and depends_on sugar does not throw exception');

no Bread::Board;

like(exception { container() },
     qr/^Undefined subroutine &main::container called/, 'container function does not exist without Bread::Board');
like(exception { as() },
     qr/^Undefined subroutine &main::as called/, 'as function does not exist without Bread::Board');
like(exception { service() },
     qr/^Undefined subroutine &main::service called/, 'service function does not exist without Bread::Board');
like(exception { depends_on() },
     qr/^Undefined subroutine &main::depends_on called/, 'depends_on function does not exist without Bread::Board');
like(exception { wire_names() },
     qr/^Undefined subroutine &main::wire_names called/, 'wire_names function does not exist without Bread::Board');

done_testing;
