#!/usr/bin/env perl
use strict;
use warnings;
use Test::More;
use Test::Moose;

use Bread::Board::ConstructorInjection;

{
    package MyLifeCycle;
    use Moose::Role;

    with 'Bread::Board::LifeCycle::Singleton';
}

{
    package MyClass;
    use Moose;
}

my $s = Bread::Board::ConstructorInjection->new(
    lifecycle => '+MyLifeCycle',
    name      => 'foo',
    class     => 'MyClass',
);

does_ok($s, 'MyLifeCycle');

done_testing;
