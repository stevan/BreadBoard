package Bread::Board::Service::WithParameters;
use Moose::Role;
use MooseX::AttributeHelpers;
use MooseX::Params::Validate;

use Bread::Board::Types;

our $VERSION = '0.01';

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

sub check_parameters {
    my $self = shift;
    return validate(\@_, %{$self->parameters})
        if $self->has_parameters;
    return ();
}

before 'get' => sub {
    my $self = shift;
    $self->params({ %{ $self->params }, $self->check_parameters(@_) });    
};

1;

__END__

=pod

=head1 NAME

Bread::Board::

=head1 SYNOPSIS

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

Stevan Little E<lt>stevan@iinteractive.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright 2007-2008 by Infinity Interactive, Inc.

L<http://www.iinteractive.com>

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut