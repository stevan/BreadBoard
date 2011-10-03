#!/usr/bin/perl

use strict;
use warnings;

use Test::More;
use Test::Moose;

BEGIN {
    use_ok('Bread::Board');
}

{
    package Stapler;
    use Moose;

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

    has 'stapler' => (
        is        => 'ro',
        isa       => 'Stapler',
        predicate => 'has_stapler'
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
ok(!$micheal->has_stapler, '... Micheal doesnt have a stapler');

isa_ok($samir, 'Employee');
is($samir->first_name, 'Samir', '... got the right first name');
is($samir->last_name, 'Nagheenanajar', '... got the right last name');
isa_ok($samir->work_area, 'Cubicle');
isa_ok($samir->work_area->desk, 'Desk');
isa_ok($samir->work_area->chair, 'Chair');
ok(!$samir->has_stapler, '... Samir doesnt have a stapler');

isnt($micheal, $samir, '... two different employees');
isnt($micheal->work_area, $samir->work_area, '... two different work_areas');
isnt($micheal->work_area->chair, $samir->work_area->chair, '... two different work_area chairs');
isnt($micheal->work_area->desk, $samir->work_area->desk, '... two different work_area desks');
isnt($micheal->keycard, $samir->keycard, '... two different keycards');
isnt($micheal->keycard->uuid, $samir->keycard->uuid, '... two different keycard uuids');

my $milton = $c->resolve(
    type       => 'Employee',
    parameters => {
        first_name => 'Milton',
        last_name  => 'Waddams',
        stapler    => Stapler->new
    }
);

isa_ok($milton, 'Employee');
is($milton->first_name, 'Milton', '... got the right first name');
is($milton->last_name, 'Waddams', '... got the right last name');
isa_ok($milton->work_area, 'Cubicle');
isa_ok($milton->work_area->desk, 'Desk');
isa_ok($milton->work_area->chair, 'Chair');
ok($milton->has_stapler, '... Milton does have a stapler');

foreach ( $micheal, $samir ) {
    isnt($milton, $_, '... two different employees');
    isnt($milton->work_area, $_->work_area, '... two different work_areas');
    isnt($milton->work_area->chair, $_->work_area->chair, '... two different work_area chairs');
    isnt($milton->work_area->desk, $_->work_area->desk, '... two different work_area desks');
    isnt($milton->keycard, $_->keycard, '... two different keycards');
    isnt($milton->keycard->uuid, $_->keycard->uuid, '... two different keycard uuids');
}

done_testing;
