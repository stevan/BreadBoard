#!/usr/bin/perl

use strict;
use warnings;

use Test::More;
use Test::Fatal;
use Test::Moose;

use Bread::Board;

{
    package Desk;
    use Moose;

    # this cannot be handled
    # so this will cause the
    # inference to die
    has 'stapler' => (
        is       => 'ro',
        isa      => 'Any',
        required => 1,
    );

    package Chair;
    use Moose;

    package Cubicle;
    use Moose;

    has 'desk' => (
        is       => 'ro',
        isa      => 'Desk',
        required => 1,
    );

    has 'chair' => (
        is       => 'ro',
        isa      => 'Chair',
        required => 1,
    );

    package Employee;
    use Moose;

    has [ 'first_name', 'last_name' ] => (
        is       => 'ro',
        isa      => 'Str',
        required => 1,
    );

    has 'work_area' => (
        is       => 'ro',
        isa      => 'Cubicle',
        required => 1,
    );
}

like(exception {
    container 'Initech' => as {
        typemap 'Employee' => infer;
    };
}, qr/Only class types\, role types\, or subtypes of Object can be inferred\. I don\'t know what to do with type \(Any\)/,
'... cannot infer a non typemapped item below the first level');


done_testing;
