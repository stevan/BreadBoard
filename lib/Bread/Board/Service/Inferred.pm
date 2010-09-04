package Bread::Board::Service::Inferred;
use Moose;
use Moose::Util::TypeConstraints 'find_type_constraint';

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

use Try::Tiny;
use Bread::Board::Types;
use Bread::Board::ConstructorInjection;

has 'current_container' => (
    is       => 'ro',
    isa      => 'Bread::Board::Container',
    required => 1,
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

    my %params = %{ $self->service_args };

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

    my $meta = try {
        $params{'class'}->meta
    } catch {
        confess "Could not get the meta object for class(" . $params{'class'} . ")";
    };

    ($meta->isa('Moose::Meta::Class'))
        || confess "We can only infer Moose classes"
                 . ($meta->isa('Moose::Meta::Role')
                        ? (', ' . $meta->name . ' is a role and therefore not concrete enough')
                        : '');

    my @attributes = grep {
        $_->is_required && $_->has_type_constraint
    } $meta->get_all_attributes;

    $params{'dependencies'} ||= {};

    foreach my $attribute (@attributes) {
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
        else {

            if (
                $type_constraint->isa('Moose::Meta::TypeConstraint::Class')
                    ||
                $type_constraint->is_subtype_of('Object')
            ) {
                $service = Bread::Board::Service::Inferred->new(
                    current_container => $self->current_container
                )->infer_service(
                    $type_name
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

    # NOTE:
    # this is always going to be
    # constructor injection because
    # that is what we do when we
    # infer. No other type of
    # injection makes sense here.
    # - SL
    my $service = Bread::Board::ConstructorInjection->new(
        name => ($type . '::__AUTO__'),
        %params
    );

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

Bread::Board::Service::Inferred - A Moosey solution to this problem

=head1 SYNOPSIS

  use Bread::Board::Service::Inferred;

=head1 DESCRIPTION

=head1 METHODS

=over 4

=item B<>

=back

=head1 BUGS

All complex software has bugs lurking in it, and this module is no
exception. If you find a bug please either email me, or add the bug
to cpan-RT.

=head1 AUTHOR

Stevan Little E<lt>stevan.little@iinteractive.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright 2010 Infinity Interactive, Inc.

L<http://www.iinteractive.com>

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
