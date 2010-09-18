#!/usr/bin/perl

use strict;
use warnings;

use Test::More;
use Test::Exception;
use Test::Moose;

BEGIN {
    use_ok('Bread::Board');
}

{
    package Desk;
    use Moose;

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

    package KeyCard;
    use Moose;
    use Moose::Util::TypeConstraints;

    subtype 'KeyCardUUID' => as 'Str';

    has 'uuid' => (
        is       => 'ro',
        isa      => 'KeyCardUUID',
        required => 1,
    );

    package Employee;
    use Moose;

    has [ 'first_name', 'last_name' ] => (
        is       => 'ro',
        isa      => 'Str',
        required => 1,
    );

    has 'keycard' => (
        is       => 'ro',
        isa      => 'KeyCard',
        required => 1,
    );

    has 'work_area' => (
        is       => 'ro',
        isa      => 'Cubicle',
        required => 1,
    );
}

my $UUID = 0;

my $c = container 'Initech' => as {

    service 'keycard_uuid_generator' => (
        block => sub { ++$UUID }
    );

    typemap 'KeyCardUUID' => 'keycard_uuid_generator';
    typemap 'Employee'    => infer;
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
        last_name  => 'Nagheenanajar'
    }
);

isa_ok($micheal, 'Employee');
is($micheal->first_name, 'Micheal', '... got the right first name');
is($micheal->last_name, 'Bolton', '... got the right last name');
isa_ok($micheal->work_area, 'Cubicle');
isa_ok($micheal->work_area->desk, 'Desk');
isa_ok($micheal->work_area->chair, 'Chair');

isa_ok($samir, 'Employee');
is($samir->first_name, 'Samir', '... got the right first name');
is($samir->last_name, 'Nagheenanajar', '... got the right last name');
isa_ok($samir->work_area, 'Cubicle');
isa_ok($samir->work_area->desk, 'Desk');
isa_ok($samir->work_area->chair, 'Chair');

isnt($micheal, $samir, '... two different employees');
isnt($micheal->work_area, $samir->work_area, '... two different work_areas');
isnt($micheal->work_area->chair, $samir->work_area->chair, '... two different work_area chairs');
isnt($micheal->work_area->desk, $samir->work_area->desk, '... two different work_area desks');
isnt($micheal->keycard, $samir->keycard, '... two different keycards');
isnt($micheal->keycard->uuid, $samir->keycard->uuid, '... two different keycard uuids');

done_testing;