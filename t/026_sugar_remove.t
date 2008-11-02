#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 10;
use Test::Exception;

use Bread::Board;

lives_ok { container 'MyApp' => sub { "dummy" } };
lives_ok { as { "Dummy" } };
lives_ok {
    container 'MyApp' => as { service 'service1' => 'foo' };
};
lives_ok {
    container 'MyApp' => as {
        service 'service1' => 'foo';
        service 'service2' => (
            block => sub { "dummy" },
            dependencies => wire_names 'service1'
        );
    }
};
lives_ok {
    container 'MyApp' => as {
        service 'service1' => 'foo';
        service 'service2' => (
            block => sub { "dummy" },
            dependencies => {
                service1 => depends_on 'service1'
            }
        );
    }
};

no Bread::Board;

throws_ok { container()  } qr/^Undefined subroutine &main::container called/;
throws_ok { as()         } qr/^Undefined subroutine &main::as called/;
throws_ok { service()    } qr/^Undefined subroutine &main::service called/;
throws_ok { depends_on() } qr/^Undefined subroutine &main::depends_on called/;
throws_ok { wire_names() } qr/^Undefined subroutine &main::wire_names called/;