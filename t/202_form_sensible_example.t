#!/usr/bin/perl

use strict;
use warnings;

use Test::More;
use Test::Exception;
use Test::Moose;

BEGIN {
    eval "use Form::Sensible 0.11220";
    plan skip_all => "This test requires Form::Sensible  0.11220 to be installed" if $@;
    use_ok('Bread::Board');
}

{
    package My::Model;
    use Moose;

    sub get_all_access_levels {
        return (
            { id => 'standard', name => 'Standard User' },
            { id => 'admin',    name => 'Administrator' },
            { id => 'super',    name => 'Super User'    },
        )
    }
}

my $FormBuilder = container 'FormBuilder' => [ 'Fields' ] => as {
    service 'Form' => (
        class => 'Form::Sensible',
        block => sub {
            my $s      = shift;
            my $c      = $s->parent;
            my $fields = $c->get_sub_container('Fields');
            my $form   = Form::Sensible::Form->new( name => $s->param('name') );
            foreach my $name ( $fields->get_service_list ) {
                $form->add_field(
                    $fields->get_service( $name )->get
                );
            }

            if ( my $state = $s->param('state') ) {
                $form->set_values( $state );
            }

            $form;
        },
        parameters => {
            name  => { isa => 'Str'                    },
            state => { isa => 'HashRef', optional => 1 },
        }
    );
};

my $Fields = container 'Fields' => [ 'Model' ] => as {

    service 'Username' => (
        class => 'Form::Sensible::Field::Text',
        block => sub {
            Form::Sensible::Field::Text->new(
                name       => 'username',
                validation => { regex => qr/^[0-9a-z]*$/ }
            );
        }
    );

    service 'Password' => (
        class => 'Form::Sensible::Field::Text',
        block => sub {
            Form::Sensible::Field::Text->new(
                name         => 'password',
                render_hints => {
                    'HTML' => {
                        field_type => 'password'
                    }
                }
            );
        }
    );

    service 'Submit' => (
        class => 'Form::Sensible::Field::Trigger',
        block => sub {
            Form::Sensible::Field::Trigger->new(
                name => 'submit'
            );
        }
    );

    service 'AccessLevel' => (
        class => 'Form::Sensible::Field::Select',
        block => sub {
            my $s = shift;
            my $select = Form::Sensible::Field::Select->new(
                 name => 'access_level',
            );
            foreach my $access_level ( $s->param('schema')->get_all_access_levels ) {
                $select->add_option(
                    $access_level->{id},
                    $access_level->{name}
                );
            }
            $select;
        },
        dependencies => {
            schema => depends_on('Model/schema') ,
        },
    );

};

# this would actually wrap the
# $c->model('DBIC') or something
# in order to get the DBIC schema
# object
my $Model = container 'Model' => as { service 'schema' => My::Model->new };

# perhaps create this in a early part
# of a catalyst dispatch chain
my $Form = $FormBuilder->create(
    Fields => $Fields->create(
        Model => $Model
    )
);

# then in the actual action code
# you would create the form instance
# and pass the state (which is
# basically $c->req->parameters)
my $f = $Form->resolve(
    service    => 'Form',
    parameters => {
        name  => 'test',
        state => {
            username     => 'stevan',
            password     => '****',
            access_level => [ 'admin' ]
        }
    }
);
isa_ok($f, 'Form::Sensible::Form');

my $result = $f->validate;

ok( $result->is_valid, '... our form validated' );


done_testing;


