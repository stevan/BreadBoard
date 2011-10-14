#!perl
use warnings;
use strict;
use Test::More;
use Bread::Board;

our $at_underscore;
our $params;

{
    package Foo;
    use Moose;
    has myattr => (
        isa => 'Int',
        is => 'rw',
    );
    has foo => (
        is       => 'rw',
        isa      => 'Str',
        required => 1,
    );
}

{
    package MyCustomWithParametersService;
    use Moose::Role;
    with 'Bread::Board::Service::WithParameters'
        =>  { -excludes => '_build_parameters' };

    sub _build_parameters {
        {
            foo => {
                isa      => 'Str',
                required => 1,
            }
        }
    }

    no Moose::Role;
}

{
    package MyCustomBlockInjection;
    use Moose;
    extends 'Bread::Board::BlockInjection';
    with 'MyCustomWithParametersService',
         'Bread::Board::Service::WithDependencies';

    around get => sub {
        my $orig = shift;
        my $self = shift;

        $at_underscore = \@_;
        $params        = $self->params;

        return $self->$orig(@_);
    };

    __PACKAGE__->meta->make_immutable;

    no Moose;
}

{
    package MyCustomConstructorInjection;
    use Moose;
    extends 'Bread::Board::ConstructorInjection';
    with 'Bread::Board::Service::WithClass',
         'MyCustomWithParametersService',
         'Bread::Board::Service::WithDependencies';

    around get => sub {
        my $orig = shift;
        my $self = shift;

        $at_underscore = \@_;
        $params        = $self->params;

        return $self->$orig(@_);
    };

    __PACKAGE__->meta->make_immutable;

    no Moose;
}

my $c = Bread::Board::Container->new( name => 'TestApp' );
$c->add_service(
    MyCustomConstructorInjection->new(
        class => 'Foo',
        name  => 'foo_ci',
        dependencies => {
            myattr => Bread::Board::Literal->new(
                name  => 'true',
                value => 1
            )
        }
    )
);
$c->add_service(
    MyCustomBlockInjection->new(
        block => sub {
            my $s = shift;
            my $foo = $s->param('foo_ci');
            $foo->myattr(2);
            return $foo;
        },
        name  => 'foo_bi',
        dependencies => {
            foo_ci => Bread::Board::Dependency->new(
                service_path => 'foo_ci',
                service_params => { foo => 'baz' },
            )
        },
    )
);
eval { $c->resolve(service => 'foo_ci') };
like($@, qr/'foo' missing/, q/Can't resolve foo_ci without mandatory attribute/);
ok(my $foo_ci = $c->resolve(service => 'foo_ci', parameters => { foo => 'bar' }), 'got the constructor injection right');
isa_ok($foo_ci, 'Foo');
is_deeply($params, { myattr => 1, foo => 'bar' }, 'params ok');
is_deeply($at_underscore, [ 'foo', 'bar' ], '@_ ok');

$foo_ci->myattr(2);
$foo_ci->foo('baz');

eval { $c->resolve(service => 'foo_bi') };
like($@, qr/'foo' missing/, q/Can't resolve foo_bi without mandatory attribute/);
ok(my $foo_bi = $c->resolve(service => 'foo_bi', parameters => { foo => 'baz' }), 'got the block injection right');
isa_ok($foo_bi, 'Foo');
is_deeply($params, { foo_ci => $foo_ci, foo => 'baz' }, 'params ok');
is_deeply($at_underscore, [ 'foo', 'baz' ], '@_ ok');

done_testing;
