package Bread::Board::Service::Inferred;
use Moose;

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

use Bread::Board::Types;
use Bread::Board::ConstructorInjection;

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

    my $meta = $params{'class'}->meta;

    my @attributes = grep { $_->is_required } $meta->get_all_attributes;

    $params{'dependencies'} = {
        map {
            $_->name,
            Bread::Board::Service::Inferred->new->infer_service(
                $_->type_constraint->name
            )
        } @attributes
    };

    Bread::Board::ConstructorInjection->new( name => ($type . '::__AUTO__'), %params );
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
