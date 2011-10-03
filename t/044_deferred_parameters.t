#!/usr/bin/perl

use strict;
use warnings;

use Test::More;
use Test::Moose;

BEGIN {
    use_ok('Bread::Board');
}

{
    package User;
    use Moose;
    has 'name' => ( is => 'ro', isa => 'Str' );

    package Page;
    use Moose;
    has 'user' => ( is => 'ro', isa => 'User' );
}

my $c = container 'Views' => as {

    service 'User' => (
        block => sub {
            my $s = shift;
            '<p>' . $s->param('user')->name . '</p>';
        },
        parameters => {
            user => { isa => 'User' }
        }
    );

    service 'Page' => (
        block => sub {
            my $s = shift;
            '<html>' .
            '<body>' .
                $s->param('user_view')->inflate(
                    user => $s->param('page')->user
                ) .
            '</body>' .
            '</html>';
        },
        dependencies => {
            user_view => depends_on('User')
        },
        parameters => {
            page => { isa => 'Page' }
        }
    );

};

my $view = $c->fetch('Page')->get(
    page => Page->new(
        user => User->new(
            name => 'Stevan'
        )
    )
);

is( $view, '<html><body><p>Stevan</p></body></html>', '... got the correct result' );


done_testing;
