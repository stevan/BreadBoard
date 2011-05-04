#!/usr/bin/env perl
use strict;
use warnings;
use Test::More;
use Test::Exception;

use Bread::Board;

{
    package Some::Class;
    use Moose;

    has foo => (
        is  => 'ro',
        isa => 'Str',
    );
}

{
    my $c = container 'MyApp' => as {
        service 'foo' => 'FOO';
        service 'bar' => (
            block => sub { 'BAR' },
        );
        service 'baz' => (
            class => 'Some::Class',
        );

        alias 'foo_alias' => 'foo';
        alias 'bar_alias' => 'bar';
        alias 'baz_alias' => 'baz';
    };

    is($c->resolve(service => 'foo_alias'), 'FOO', "literal aliases work");
    is($c->resolve(service => 'bar_alias'), 'BAR', "block aliases work");
    isa_ok($c->resolve(service => 'baz_alias'), 'Some::Class');

    is($c->fetch('foo_alias')->name, 'foo',
       "fetch on aliases returns the underlying service");
}

{
    my $c = container 'MyApp' => as {
        service 'foo' => 'FOO';
        service 'bar' => (
            block => sub {
                my $s = shift;
                return $s->param('foo') . 'BAR';
            },
            dependencies => ['foo'],
        );
        service 'baz' => (
            class => 'Some::Class',
            dependencies => ['foo'],
        );

        alias 'bar_alias' => 'bar';
        alias 'baz_alias' => 'baz';
    };

    is($c->resolve(service => 'bar_alias'), 'FOOBAR',
       "block aliases with deps work");
    is($c->resolve(service => 'baz_alias')->foo, 'FOO',
       "constructor aliases with deps work");
}

{
    my $c = container 'MyApp' => as {
        service 'real_foo' => 'FOO';
        service 'bar' => (
            block => sub {
                my $s = shift;
                return $s->param('foo') . 'BAR';
            },
            dependencies => ['foo'],
        );
        service 'baz' => (
            class => 'Some::Class',
            dependencies => ['foo'],
        );

        alias 'foo' => 'real_foo';
    };

    is($c->resolve(service => 'bar'), 'FOOBAR',
       "blocks can dep on aliases");
    is($c->resolve(service => 'baz')->foo, 'FOO',
       "constructor injections can dep on aliases");
}

{
    my $c = container 'MyApp' => as {
        service 'foo' => (
            block => sub {
                my $s = shift;
                return 'FOO' . $s->param('sub_bar');
            },
            dependencies => ['sub_bar'],
        );

        alias 'sub_bar' => 'SubApp/bar1';

        container 'SubApp' => as {
            service 'bar1' => 'BAR';
            service 'bar2' => (
                block => sub {
                    my $s = shift;
                    return 'BAR'
                         . $s->param('parent_foo')
                         . $s->param('root_foo')
                         . $s->param('sub_baz');
                },
                dependencies => ['parent_foo', 'root_foo', 'sub_baz'],
            );

            alias 'parent_foo' => '../foo';
            alias 'root_foo' => '/foo';
            alias 'sub_baz' => 'SubSubApp/baz1';

            container 'SubSubApp' => as {
                service 'baz1' => 'BAZ';
                service 'baz2' => (
                    block => sub {
                        my $s = shift;
                        return 'BAZ'
                             . $s->param('parent_bar')
                             . $s->param('parent_foo')
                             . $s->param('root_foo');
                    },
                    dependencies => ['parent_bar', 'parent_foo', 'root_foo'],
                );

                alias 'parent_bar' => '../bar1';
                alias 'parent_foo' => '../../foo';
                alias 'root_foo' => '/foo';
            };
        };
    };

    is($c->resolve(service => 'foo'), 'FOOBAR',
       "aliases to nested containers work");
    is($c->resolve(service => 'sub_bar'), 'BAR',
       "aliases to nested containers work");
    is($c->resolve(service => 'SubApp/bar1'), 'BAR',
       "aliases to nested containers work");
    is($c->resolve(service => 'SubApp/bar2'), 'BARFOOBARFOOBARBAZ',
       "aliases to nested containers work");
    is($c->resolve(service => 'SubApp/parent_foo'), 'FOOBAR',
       "aliases to nested containers work");
    is($c->resolve(service => 'SubApp/root_foo'), 'FOOBAR',
       "aliases to nested containers work");
    is($c->resolve(service => 'SubApp/sub_baz'), 'BAZ',
       "aliases to nested containers work");
    is($c->resolve(service => 'SubApp/SubSubApp/baz1'), 'BAZ',
       "aliases to nested containers work");
    is($c->resolve(service => 'SubApp/SubSubApp/baz2'), 'BAZBARFOOBARFOOBAR',
       "aliases to nested containers work");
    is($c->resolve(service => 'SubApp/SubSubApp/parent_bar'), 'BAR',
       "aliases to nested containers work");
    is($c->resolve(service => 'SubApp/SubSubApp/parent_foo'), 'FOOBAR',
       "aliases to nested containers work");
    is($c->resolve(service => 'SubApp/SubSubApp/root_foo'), 'FOOBAR',
       "aliases to nested containers work");
}

{
    my $c = container 'MyApp' => as {
        service 'foo' => 'FOO';
        alias 'foo1' => 'foo';
        alias 'foo2' => 'foo1';
    };

    is($c->resolve(service => 'foo2'), 'FOO', "multi-level aliases work");
    is($c->fetch('foo2')->name, 'foo', "multi-level fetching works");
}

{
    my $c;
    lives_ok {
        $c = container 'MyApp' => as {
            alias 'foo' => 'doesnt_exist';

            alias 'a' => 'a';

            alias 'b' => 'c';
            alias 'c' => 'b';

            alias 'd' => 'e';
            alias 'e' => 'f';
            alias 'f' => 'd';
        };
    } "bad aliases don't die on creation";

    throws_ok {
        $c->resolve(service => 'foo');
    } qr/^While resolving alias foo: Could not find container or service for doesnt_exist in MyApp/,
      "error when aliasing to something that doesn't exist";
    throws_ok {
        $c->resolve(service => 'a');
    } qr/^Cycle detected in aliases/,
      "error with self-referencing aliases";
    throws_ok {
        $c->resolve(service => 'b');
    } qr/^Cycle detected in aliases/,
      "error with circular aliases";
    throws_ok {
        $c->resolve(service => 'd');
    } qr/^Cycle detected in aliases/,
      "error with circular aliases with larger cycles";

    throws_ok {
        $c->fetch('a');
    } qr/^Cycle detected in aliases/,
      "error with self-referencing aliases";
    throws_ok {
        $c->fetch('b');
    } qr/^Cycle detected in aliases/,
      "error with circular aliases";
    throws_ok {
        $c->fetch('d');
    } qr/^Cycle detected in aliases/,
      "error with circular aliases with larger cycles";
}

{
    my $c = container 'MyApp' => as {
        service 'foo' => (
            class     => 'Some::Class',
            lifecycle => 'Singleton',
        );
        alias 'foo_alias' => 'foo';
    };

    is($c->resolve(service => 'foo'), $c->resolve(service => 'foo'),
       "same object, since it's a singleton");
    is($c->resolve(service => 'foo_alias'), $c->resolve(service => 'foo_alias'),
       "same object, since it's a singleton");
}

done_testing;
