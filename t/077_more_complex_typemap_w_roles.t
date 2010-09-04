#!/usr/bin/perl

use strict;
use warnings;

use Test::More;
use Test::Exception;
use Test::Moose;

BEGIN {
    use_ok('Bread::Board');
}

{ # Abstract items ...
    package Desk;
    use Moose::Role;

    package Chair;
    use Moose::Role;

    package WorkArea;
    use Moose::Role;

    has 'desk' => (
        is       => 'ro',
        does     => 'Desk',
        required => 1,
    );

    has 'chair' => (
        is       => 'ro',
        does     => 'Chair',
        required => 1,
    );
}

# crappy stuff
{
    package CheapMetalDesk;
    use Moose;
    with 'Desk';

    package CheapOfficeChair;
    use Moose;
    with 'Chair';

    package Cubicle;
    use Moose;
    with 'WorkArea';
}

# good stuff
{
    package NiceWoodenDesk;
    use Moose;
    with 'Desk';

    package AeronChair;
    use Moose;
    with 'Chair';

    package Office;
    use Moose;
    with 'WorkArea';
}

{
    package Employee;
    use Moose;

    has [ 'first_name', 'last_name' ] => (
        is       => 'ro',
        isa      => 'Str',
        required => 1,
    );

    has 'work_area' => (
        is       => 'ro',
        does     => 'WorkArea',
        required => 1,
    );

    package Manager;
    use Moose;

    extends 'Employee';

    has '+work_area' => ( isa => 'Office' );
}

my $c = container 'Initech' => as {

    # Employees ...
    typemap 'Desk'     => infer( class => 'CheapMetalDesk' );
    typemap 'Chair'    => infer( class => 'CheapOfficeChair' );
    typemap 'WorkArea' => infer( class => 'Cubicle' );

    # Managers ...
    service 'managers_desk'  => (class => 'NiceWoodenDesk');
    service 'managers_chair' => (class => 'AeronChair');
    typemap 'Office'         => infer(
        dependencies => {
            desk  => depends_on('managers_desk'),
            chair => depends_on('managers_chair')
        }
    );

    typemap 'Employee' => infer;
    typemap 'Manager'  => infer;
};

my $micheal = $c->resolve(
    type       => 'Employee',
    parameters => {
        first_name => 'Micheal',
        last_name  => 'Bolton'
    }
);
my $samir = $c->resolve(
    type       => 'Employee',
    parameters => {
        first_name => 'Samir',
        last_name  => 'Something'
    }
);

isa_ok($micheal, 'Employee');
is($micheal->first_name, 'Micheal', '... got the right first name');
is($micheal->last_name, 'Bolton', '... got the right last name');

does_ok($micheal->work_area, 'WorkArea');
isa_ok($micheal->work_area, 'Cubicle');

does_ok($micheal->work_area->desk, 'Desk');
isa_ok($micheal->work_area->desk, 'CheapMetalDesk');

does_ok($micheal->work_area->chair, 'Chair');
isa_ok($micheal->work_area->chair, 'CheapOfficeChair');

isa_ok($samir, 'Employee');
is($samir->first_name, 'Samir', '... got the right first name');
is($samir->last_name, 'Something', '... got the right last name');

does_ok($samir->work_area, 'WorkArea');
isa_ok($samir->work_area, 'Cubicle');

does_ok($samir->work_area->desk, 'Desk');
isa_ok($samir->work_area->desk, 'CheapMetalDesk');

does_ok($samir->work_area->chair, 'Chair');
isa_ok($samir->work_area->chair, 'CheapOfficeChair');

isnt($micheal, $samir, '... two different employees');
isnt($micheal->work_area, $samir->work_area, '... two different cubicles');
isnt($micheal->work_area->chair, $samir->work_area->chair, '... two different cubicle chairs');
isnt($micheal->work_area->desk, $samir->work_area->desk, '... two different cubicle desks');

# managers

my $lundberg = $c->resolve(
    type       => 'Manager',
    parameters => {
        first_name => 'Dean',
        last_name  => 'Lundberg'
    }
);

isa_ok($lundberg, 'Manager');
is($lundberg->first_name, 'Dean', '... got the right first name');
is($lundberg->last_name, 'Lundberg', '... got the right last name');

does_ok($lundberg->work_area, 'WorkArea');
isa_ok($lundberg->work_area, 'Office');

does_ok($lundberg->work_area->desk, 'Desk');
isa_ok($lundberg->work_area->desk, 'NiceWoodenDesk');

does_ok($lundberg->work_area->chair, 'Chair');
isa_ok($lundberg->work_area->chair, 'AeronChair');

done_testing;