package Bread::Board::LifeCycle::Singleton;
our $AUTHORITY = 'cpan:STEVAN';
# ABSTRACT: service role for singleton lifecycle
$Bread::Board::LifeCycle::Singleton::VERSION = '0.35';
use Moose::Role;

use Try::Tiny;

with 'Bread::Board::LifeCycle';

has 'instance' => (
    traits    => [ 'NoClone' ],
    is        => 'rw',
    isa       => 'Any',
    predicate => 'has_instance',
    clearer   => 'flush_instance'
);

has 'resolving_singleton' => (
    traits  => [ 'NoClone' ],
    is      => 'rw',
    isa     => 'Bool',
    default => 0,
);

around 'get' => sub {
    my $next = shift;
    my $self = shift;

    # return it if we got it ...
    return $self->instance if $self->has_instance;

    my $instance;
    if ($self->resolving_singleton) {
        $instance = Bread::Board::Service::Deferred->new(service => $self);
    }
    else {
        $self->resolving_singleton(1);
        my @args = @_;
        try {
            # otherwise fetch it ...
            $instance = $self->$next(@args);
        }
        catch {
            die $_;
        }
        finally {
            $self->resolving_singleton(0);
        };
    }

    # if we get a copy, and our copy
    # has not already been set ...
    $self->instance($instance);

    # return whatever we have ...
    return $self->instance;
};

no Moose::Role; 1;

__END__

=pod

=encoding UTF-8

=head1 NAME

Bread::Board::LifeCycle::Singleton - service role for singleton lifecycle

=head1 VERSION

version 0.35

=head1 DESCRIPTION

Sub-role of L<Bread::Board::LifeCycle>, this role defines the
"singleton" lifecycle for a service. The C<get> method will only do
its work the first time it is invoked; subsequent invocations will
return the same object.

=head1 ATTRIBUTES

=head2 C<instance>

The object build by the last call to C<get> to actually do any work,
and returned by any subsequent call to C<get>.

=head1 METHODS

=head2 C<get>

The first time this is called (or the first time after calling
L</flush_instance>), the actual C<get> method will be invoked, and its
return value cached in the L</instance> attribute. The value of that
attribute will always be returned, so you can call C<get> as many time
as you need, and always receive the same instance.

=head2 C<has_instance>

Predicate for the L</instance> attribute.

=head2 C<flush_instance>

Clearer for the L</instance> attribute. Clearing the attribute will
cause the next call to C<get> to instantiate a new object.

=head1 AUTHOR

Stevan Little <stevan@iinteractive.com>

=head1 BUGS

Please report any bugs or feature requests on the bugtracker website
https://github.com/stevan/BreadBoard/issues

When submitting a bug or request, please include a test-file or a
patch to an existing test-file that illustrates the bug or desired
feature.

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2017, 2016, 2015, 2014, 2013, 2011, 2009 by Infinity Interactive.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
