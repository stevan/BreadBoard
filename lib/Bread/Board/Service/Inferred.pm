package Bread::Board::Service::Inferred;
use Moose;

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

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

sub infer_service {
    my $self   = shift;
    my $type   = shift;
    my %params = %{ $self->service_args };

    unless ( exists $params{'class'} ) {
        # TODO:
        # check here to make sure that
        # the type is a subtype of Object
        # and we know we can use it
        # - SL
        $params{'class'} = $type;
    }

    my @attributes = grep {
        # TODO:
        # check to make sure we
        # are dealing with Moose
        # attributes here, and ...
        $_->is_required
        &&
        # We also need to make sure
        # that there is a type constraint
        # that we can work with and not
        # just a type constraint.
        # - SL
        $_->has_type_constraint
    } $params{'class'}->meta->get_all_attributes;

    $params{'dependencies'} = {
        map {
            my $name = $_->name;
            my $type = $_->type_constraint;

            # TODO:
            # We need to be checking for
            # an existing type-mapping here
            # before we actually go about
            # making one.
            # - SL

            # TODO:
            # We need to inspect the
            # type more and probably
            # call something other then
            # just ->name on it.
            # - SL
            my $service = Bread::Board::Service::Inferred->new(
                current_container => $self->current_container
            )->infer_service(
                $type->name
            );
            # TODO:
            # we should also be adding
            # this service to the typemapping.
            # - SL

            ($name, $service);
        } @attributes
    };

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

    $self->current_container->add_service( $service );
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
