#!/usr/bin/env perl
use strict;
use warnings;
use Test::More;

use Bread::Board;

{
    package NonMoose;
    sub new { bless { data => $_[0] }, shift }
}

{
    package Foo;
    use Moose;
}

{
    package Bar;
    use Moose;

    has foo => (
        is       => 'ro',
        isa      => 'Foo',
        required => 1,
    );
}

{
	package NotMoosey;
	use Moose::Role;

    has non_moose => (
        is       => 'ro',
        isa      => 'NonMoose',
        required => 1,
    );
}

{
    package Bar;
    use Moose;

    has foo => (
        is       => 'ro',
        isa      => 'Foo',
        required => 1,
    );
}

{
    my $c = container Stuff => as {
        service non_moose => NonMoose->new("foo");
        service foo => (
            class        => 'Foo',
			roles        => ['NotMoosey']
        );
        typemap 'Foo' => 'foo';
        typemap 'Bar' => infer;
    };

    my $bar = $c->resolve(type => 'Bar');
    isa_ok($bar->foo->non_moose, 'NonMoose');
}

done_testing;
__END__

{
    package Foo::Sub;
    use Moose;

    extends 'Foo';
}

{
    my $c = container Stuff => as {
        service non_moose => NonMoose->new("foo");
        service foo => (
            class        => 'Foo::Sub',
            dependencies => ['non_moose'],
        );
        typemap 'Foo::Sub' => 'foo';
        typemap 'Bar' => infer;
    };

    my $bar = $c->resolve(type => 'Bar');
    isa_ok($bar->foo->non_moose, 'NonMoose');
}

done_testing;
