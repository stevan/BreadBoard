#!/usr/bin/perl

use strict;
use warnings;

use Test::More;
use Test::Exception;

BEGIN {
    use_ok('Bread::Board');
}

{
    package My::Form;
    use Moose;

    has 'fields' => (
        is       => 'ro',
        isa      => 'ArrayRef[My::Form::Field]',
        required => 1
    );

    has 'state' => (
        is       => 'ro',
        isa      => 'HashRef',
        required => 1,
    );

    package My::Form::Field;
    use Moose;

    has 'name' => (
        is       => 'ro',
        isa      => 'Str',
        required => 1,
    );

    package My::Form::Field::Text;
    use Moose;

    extends 'My::Form::Field';

    has 'validations' => (
        is       => 'ro',
        isa      => 'Regexp',
        required => 1,
    );

    package My::Form::Field::Select;
    use Moose;

    extends 'My::Form::Field';

    has 'options' => (
        is       => 'ro',
        isa      => 'ArrayRef[HashRef]',
        required => 1,
    );

    package My::Model;
    use Moose;

    sub get_all_states {
        return [
            { value => 'CT', name => 'Connecticut' },
            { value => 'CO', name => 'Colorado'    },
            { value => 'CA', name => 'California'  },
        ]
    }
}

my $FormBuilder = container 'Form' => [ 'Fields' ] => as {
    service 'form' => (
        class => 'My::Form',
        block => sub {
            my $s = shift;
            my $c = $s->parent->get_sub_container('Fields');
            return My::Form->new(
                state  => $s->param('state'),
                fields => [
                    map {
                        $c->fetch( $_ )->get;
                    } reverse sort $c->get_service_list
                ]
            );
        },
        parameters => {
            state => { isa => 'HashRef' }
        }
    );
};
isa_ok($FormBuilder, 'Bread::Board::Container::Parameterized');

my $fields = container 'Fields' => [ 'Model' ] => as {
    service 'username' => (
        class      => 'My::Form::Field::Text',
        parameters => {
            name        => { isa => 'Str',    default => 'username'          },
            validations => { isa => 'Regexp', default => qr/^[a-zA-Z0-9_]*$/ },
        }
    );

    service 'states' => (
        class => 'My::Form::Field::Select',
        block => sub {
            my $s = shift;
            My::Form::Field::Select->new(
                name    => 'states',
                options => $s->param('schema')->get_all_states,
            );
        },
        dependencies => {
            schema => depends_on('Model/schema') ,
        },
    );

};
isa_ok($fields, 'Bread::Board::Container::Parameterized');

my $model = container 'Model' => as {
    service 'schema' => My::Model->new;
};
isa_ok($model, 'Bread::Board::Container');

my $form = $FormBuilder->create( Fields => $fields->create( Model => $model ) );
isa_ok($form, 'Bread::Board::Container');

my $f = $form->fetch('form')->get(
    state => { username => 'stevan', state => 'CT' }
);
isa_ok($f, 'My::Form');

is_deeply(
    $f->state,
    { username => 'stevan', state => 'CT' },
    '... got the right state'
);

my $username = $f->fields->[0];
isa_ok($username, 'My::Form::Field::Text');
isa_ok($username, 'My::Form::Field');

is($username->name, 'username', '... got the right name');
ok(ref $username->validations eq 'Regexp', '... got the right validation');

my $states = $f->fields->[1];
isa_ok($states, 'My::Form::Field::Select');
isa_ok($states, 'My::Form::Field');

is($states->name, 'states', '... got the right name');
is_deeply(
    $states->options,
    [
        { value => 'CT', name => 'Connecticut' },
        { value => 'CO', name => 'Colorado'    },
        { value => 'CA', name => 'California'  },
    ],
    '... got the right option list'
);

done_testing;





