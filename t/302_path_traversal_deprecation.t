#!/usr/bin/env perl
use strict;
use warnings;
use Test::More;

use Bread::Board;

my $c = container 'Foo' => as {
    service bar => 'baz';
};

{
    my $warning;
    local $SIG{__WARN__} = sub { $warning = $_[0] };

    my $baz = $c->resolve(service => '/Foo/bar');
    is($baz, 'baz', 'resolving service path in deprecated way still works');
    like($warning, qr/Traversing into the current container \(Foo\) is deprecated; you should remove the Foo component from the path/, '... but gives a nice warning');
}

done_testing;
