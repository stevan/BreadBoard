package Bread::Board::Service::WithParameters;
use Moose::Role;
use MooseX::AttributeHelpers;
use MooseX::Params::Validate qw(validated_hash);

use Bread::Board::Types;

our $VERSION   = '0.02';
our $AUTHORITY = 'cpan:STEVAN';

with 'Bread::Board::Service';

has 'parameters' => (
    metaclass => 'Collection::Hash',
    is        => 'ro',
    isa       => 'Bread::Board::Service::Parameters',
    lazy      => 1,
    coerce    => 1,
    default   => sub { +{} },
    provides  => {
        'empty'  => 'has_parameters',
    }
);

before 'get' => sub {
    my $self = shift;
    $self->params({ %{ $self->params }, $self->check_parameters(@_) });    
};

no Moose::Role;

sub check_parameters {
    my $self = shift;
    return validated_hash(\@_, (
        %{ $self->parameters },
        # NOTE:
        # cache the parameters in a per-service 
        # basis, this should be more than adequate
        # since each service can only have one set
        # of parameters at a time. If this does end
        # up breaking then we can give it a better 
        # key at that point.
        # - SL
        (MX_PARAMS_VALIDATE_CACHE_KEY => Scalar::Util::refaddr($self))
    )) if $self->has_parameters;
    return ();
}

1;

__END__

=pod

=head1 NAME

Bread::Board::Service::WithParameters

=head1 DESCRIPTION

=head1 METHODS

=over 4

=item B<get>

=item B<parameters>

=item B<has_parameters>

=item B<check_parameters>

=back

=head1 BUGS

All complex software has bugs lurking in it, and this module is no
exception. If you find a bug please either email me, or add the bug
to cpan-RT.

=head1 AUTHOR

Stevan Little E<lt>stevan@iinteractive.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright 2007-2008 by Infinity Interactive, Inc.

L<http://www.iinteractive.com>

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut