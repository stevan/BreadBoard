package Bread::Board::Service::Inferred;
use Moose;
use Moose::Util::TypeConstraints 'find_type_constraint';

our $VERSION   = '0.19';
our $AUTHORITY = 'cpan:STEVAN';

use Try::Tiny;
use Bread::Board::Types;
use Bread::Board::ConstructorInjection;

has 'current_container' => (
    is       => 'ro',
    isa      => 'Bread::Board::Container',
    required => 1,
);

has 'service' => (
    is        => 'ro',
    isa       => 'Bread::Board::ConstructorInjection',
    predicate => 'has_service',
);

has 'service_args' => (
    is      => 'ro',
    isa     => 'HashRef',
    lazy    => 1,
    default => sub { +{} }
);

has 'infer_params' => (
    is      => 'ro',
    isa     => 'Bool',
    default => sub { 0 },
);

sub infer_service {
    my $self              = shift;
    my $type              = shift;
    my $seen              = shift || {};
    my $type_constraint   = find_type_constraint( $type );
    my $current_container = $self->current_container;

    # the type must exist ...
    (defined $type_constraint)
        || confess "$type is not an existing valid Moose type";

    # the type must be either
    # a class type, or a subtype
    # of object.
    ($type_constraint->isa('Moose::Meta::TypeConstraint::Class')
        ||
    $type_constraint->is_subtype_of('Object'))
        || confess 'Only class types, role types, or subtypes of Object can be inferred. '
                 . 'I don\'t know what to do with type (' . $type_constraint->name . ')';

    my %params = (
        name => 'type:' . $type,
    );

    if ($self->has_service) {
        my $service = $self->service;
        %params = (
            %params,
            name         => $service->name,
            class        => $service->class,
            dependencies => $service->dependencies,
            parameters   => $service->parameters,
        );
    }
    else {
        %params = (
            %params,
            %{ $self->service_args }
        );
    }

    # if the class is specified, then
    # we can use that reliably, otherwise
    # we need to try and figure out the
    # class name ...
    unless ( exists $params{'class'} ) {
        # if it is a class type, it is easy
        if ($type_constraint->isa('Moose::Meta::TypeConstraint::Class')) {
            $params{'class'} = $type_constraint->class;
        }
        # if it is not a class type, then
        # we will make the assumption that
        # the name of the type constraint
        # is also the name of the class.
        else {
            $params{'class'} = $type_constraint->name;
        }
    }

    my $meta = Class::MOP::class_of($params{'class'})
        || confess "Could not get the meta object for class(" . $params{'class'} . ")";

    ($meta->isa('Moose::Meta::Class'))
        || confess "We can only infer Moose classes"
                 . ($meta->isa('Moose::Meta::Role')
                        ? (', ' . $meta->name . ' is a role and therefore not concrete enough')
                        : '');

    my @required_attributes = grep {
        $_->is_required && $_->has_type_constraint
    } $meta->get_all_attributes;

    $params{'dependencies'} ||= {};
    $params{'parameters'}   ||= {};

    # defer this for now ...
    $seen->{ $type } = $params{'name'};

    foreach my $attribute (@required_attributes) {
        my $name = $attribute->name;

        next if exists $params{'dependencies'}->{ $name };

        my $type_constraint = $attribute->type_constraint;
        my $type_name       = $type_constraint->isa('Moose::Meta::TypeConstraint::Class')
            ? $type_constraint->class
            : $type_constraint->name;

        my $service;
        if ($current_container->has_type_mapping_for( $type_name )) {
            $service = $current_container->get_type_mapping_for( $type_name )
        }
        elsif ( exists $seen->{ $type_name } ) {
            if ( blessed($seen->{ $type_name }) ) {
                # if the type has already been
                # inferred, then we use it
                $service = $seen->{ $type_name };
            }
            else {
                # if not, then we have to use
                # the built in laziness and
                # make it a dependency
                $service = Bread::Board::Dependency->new(
                    service_path => $seen->{ $type_name }
                );
            }
        }
        else {
            if (
                $type_constraint->isa('Moose::Meta::TypeConstraint::Class')
                    ||
                $type_constraint->is_subtype_of('Object')
            ) {
                $service = Bread::Board::Service::Inferred->new(
                    current_container => $self->current_container
                )->infer_service(
                    $type_name,
                    $seen
                );
            } else {
                if ($self->infer_params) {
                    $params{'parameters'}->{ $name } = { isa => $type_name };
                }
                else {
                    confess 'Only class types, role types, or subtypes of Object can be inferred. '
                             . 'I don\'t know what to do with type (' . $type_name . ')';
                }
            }
        }

        $params{'dependencies'}->{ $name } = $service
            if defined $service;
    }

    if ( $self->infer_params ) {
        map {
            $params{'parameters'}->{ $_->name } = {
                optional => 1,
                ($_->has_type_constraint
                    ? ( isa => $_->type_constraint )
                    : ())
            };
        } grep {
            ( not $_->is_required )
        } $meta->get_all_attributes
    }

    # NOTE:
    # this is always going to be
    # constructor injection because
    # that is what we do when we
    # infer. No other type of
    # injection makes sense here.
    # - SL
    my $service;
    if ($self->has_service) {
        $service = $self->service->clone(%params);
    }
    else {
        $service = Bread::Board::ConstructorInjection->new(%params);
    }

    # NOTE:
    # We need to do this so that
    # anything created by a typemap
    # can still also refer back to
    # an actual service in the parent
    # container.
    # - SL
    $self->current_container->add_service( $service );

    $service;
}

__PACKAGE__->meta->make_immutable;

no Moose; 1;

__END__

=pod

=head1 NAME

Bread::Board::Service::Inferred

=head1 DESCRIPTION

CAUTION, EXPERIMENTAL FEATURE.

Docs to come, as well as refactoring.

=head1 BUGS

All complex software has bugs lurking in it, and this module is no
exception. If you find a bug please either email me, or add the bug
to cpan-RT.

=head1 AUTHOR

Stevan Little E<lt>stevan.little@iinteractive.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright 2010-2011 Infinity Interactive, Inc.

L<http://www.iinteractive.com>

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
