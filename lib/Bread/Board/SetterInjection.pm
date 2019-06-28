package Bread::Board::SetterInjection;
our $AUTHORITY = 'cpan:STEVAN';
# ABSTRACT: service instantiating objects via setter functions
$Bread::Board::SetterInjection::VERSION = '0.37';
use Moose;

use Bread::Board::Types;

with 'Bread::Board::Service::WithConstructor',
     'Bread::Board::Service::WithParameters',
     'Bread::Board::Service::WithDependencies';

has '+class' => (required => 1);

sub get {
    my $self = shift;
    my $constructor = $self->constructor_name;
    my $o = $self->class->$constructor();
    $o->$_($self->param($_)) foreach $self->param;
    return $o;
}

__PACKAGE__->meta->make_immutable;

no Moose; 1;

__END__

=pod

=encoding UTF-8

=head1 NAME

Bread::Board::SetterInjection - service instantiating objects via setter functions

=head1 VERSION

version 0.37

=head1 DESCRIPTION

This L<service|Bread::Board::Service> class instantiates objects by
calling C<new> on a class, then calling setters on the returned
object.

This class consumes L<Bread::Board::Service::WithClass>,
L<Bread::Board::Service::WithParameters>,
L<Bread::Board::Service::WithDependencies>.

=head1 ATTRIBUTES

=head2 C<class>

Attribute provided by L<Bread::Board::Service::WithClass>. This
service makes it a required attribute: you can't call a constructor if
you don't have a class.

=head1 METHODS

=head2 C<get>

Calls the C<new> method on the L</class> to get the object to return;
then, for each of the L<service
parameters|Bread::Board::Service/params>, calls a setter with the same
name as the parameter, passing it the parameter's value.

=head1 AUTHOR

Stevan Little <stevan@iinteractive.com>

=head1 BUGS

Please report any bugs or feature requests on the bugtracker website
https://github.com/stevan/BreadBoard/issues

When submitting a bug or request, please include a test-file or a
patch to an existing test-file that illustrates the bug or desired
feature.

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2019, 2017, 2016, 2015, 2014, 2013, 2011, 2009 by Infinity Interactive.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
