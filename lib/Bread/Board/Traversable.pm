package Bread::Board::Traversable;
use Moose::Role;

our $VERSION   = '0.08';
our $AUTHORITY = 'cpan:STEVAN';

with 'MooseX::Clone';

has 'parent' => (
    is        => 'rw',
    isa       => 'Bread::Board::Traversable',
    weak_ref  => 1,
    clearer   => 'detach_from_parent',
    predicate => 'has_parent',
);

sub get_root_container {
    my $c = shift;
    while ($c->has_parent) {
        $c = $c->parent;
    }
    return $c;
}

sub fetch {
    my ($self, $path) = @_;

    my $root = $path =~ /^\// ? $self->get_root_container : $self;
    my @path = grep { $_ } split /\// => $path;

    if ($path[0] eq '..') {
        my $c = $root;
        do {
            shift @path;
            $c = $c->parent;
        } while (defined $path[0] && $path[0] eq '..' && $c->has_parent);
        $root = $c;
    }

    return $root unless @path;

    my $c = $root;
    while (my $h = shift @path) {
        $c = _get_container_or_service($c, $h);
    }
    return $c;
}

sub _get_container_or_service {
    my ($c, $name) = @_;

    if ($c->isa('Bread::Board::Dependency')) {
        # make sure to evaluate this from the parent
        return _get_container_or_service($c->parent->parent, $name);
    }

    if ($c->does('Bread::Board::Service::WithDependencies')) {
        return $c->get_dependency($name) if $c->has_dependency($name);
        confess "Could not find dependency ($name) from service " . $c->name;
    }

    # name() is implemented in Service and Container
    # get_sub_container and get_service is implemented in Container
    # there must be a better way to do this

    if ($c->does('Bread::Board::Service')) {
        return $c                           if $c->name eq $name;
    } elsif ($c->isa('Bread::Board::Container')) {
        return $c                           if $c->name eq $name;
        return $c->get_sub_container($name) if $c->has_sub_container($name);
        return $c->get_service($name)       if $c->has_service($name);
    }

    confess "Could not find container or service for $name";
}

no Moose::Role; 1;

__END__

=pod

=head1 NAME

Bread::Board::Traversable

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 METHODS

=over 4

=item B<parent>

=item B<has_parent>

=item B<detach_from_parent>

=item B<get_root_container>

=item B<fetch>

=back

=head1 BUGS

All complex software has bugs lurking in it, and this module is no
exception. If you find a bug please either email me, or add the bug
to cpan-RT.

=head1 AUTHOR

Stevan Little E<lt>stevan@iinteractive.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright 2007-2009 by Infinity Interactive, Inc.

L<http://www.iinteractive.com>

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut