#!/usr/bin/perl

use strict;
use warnings;

use Test::More;

use Bread::Board;

{
    package Stapler;
    use Moose;
    package Desk;
    use Moose;
    has 'stapler' => ( is => 'ro', isa => 'Stapler', required => 1 );

    package Employee;
    use Moose;
    has 'desk' => ( is => 'ro', isa => 'Desk' );
}


my $c = container 'TypeDependencyTest' => as {
    typemap 'Desk' => infer;

    service 'Employee' => (
        class => 'Employee',
        dependencies => {
            desk => 'type:Desk'
        }
    );
};

my $desk = $c->resolve( type => 'Desk' );
isa_ok($desk, 'Desk');
isa_ok($desk->stapler, 'Stapler');

my $employee = $c->resolve( service => 'Employee' );
isa_ok($employee, 'Employee');
isa_ok($employee->desk, 'Desk');
isa_ok($employee->desk->stapler, 'Stapler');

done_testing;
