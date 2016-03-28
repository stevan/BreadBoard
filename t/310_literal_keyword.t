use strict;
use warnings;

use Test::More tests => 1;

use Bread::Board;

my $c = container 'Main' => as {
    service with_literal => (
        block => sub { $_[0]->param('foo') . join '', @{ $_[0]->param('bar') } },
        dependencies => {
            foo => literal( 'fantastic' ),
            bar => literal( [ 1..5 ] ),
        },
    );
};

is $c->resolve( service => 'with_literal' ) => 'fantastic12345', 'got expected service string from literals';



