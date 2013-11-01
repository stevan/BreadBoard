#!/usr/bin/perl

use strict;
use warnings;

use Test::More;
use Test::Moose;
use Test::Fatal;

use Bread::Board::ConstructorInjection;
use Bread::Board::Literal;

{
    package Sterile;
    use Moose::Role;

    package Needle;
    use Moose;

    package Mexican::Black::Tar;
    use Moose;

    package Addict;
    use Moose;

    sub shoot_up_good { shift->new(@_, overdose => 1) }

    has 'needle' => (is => 'ro');
    has 'spoon'  => (is => 'ro');
    has 'stash'  => (is => 'ro');
    has 'overdose' => (is => 'ro', isa => 'Bool', default => 0);
}

my $s = Bread::Board::ConstructorInjection->new(
    name  => 'William',
    class => 'Addict',
    dependencies => {
        needle => Bread::Board::ConstructorInjection->new(
			name  => 'spike',
			class => 'Needle',
			roles => ['Sterile'], # I need sterile needle's yo
		),
        spoon  => Bread::Board::Literal->new(name => 'works', value => 'Spoon!'),
    },
    parameters => {
        stash => { isa => 'Mexican::Black::Tar' }
    }
);
isa_ok($s, 'Bread::Board::ConstructorInjection');
does_ok($s, 'Bread::Board::Service::WithClass');
does_ok($s, 'Bread::Board::Service::WithDependencies');
does_ok($s, 'Bread::Board::Service::WithParameters');
does_ok($s, 'Bread::Board::Service');

{
    my $i = $s->get(stash => Mexican::Black::Tar->new);

    isa_ok($i, 'Addict');
    isa_ok($i->needle, 'Needle');
	does_ok( $i->needle, 'Sterile' );
	ok( $i->needle->meta->is_immutable, 'is immutable' );
    is($i->spoon, 'Spoon!', '... got our literal service');
    isa_ok($i->stash, 'Mexican::Black::Tar');
    ok ! $i->overdose, 'Normal constructor';
}

done_testing;
