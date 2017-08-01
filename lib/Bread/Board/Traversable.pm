package Bread::Board::Traversable;
our $AUTHORITY = 'cpan:STEVAN';
# ABSTRACT: role for traversing a container service tree
$Bread::Board::Traversable::VERSION = '0.35';
use Moose::Role;

with 'MooseX::Clone' => { -version => 0.05 };

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

    my $root;
    if ($path =~ /^\//) {
        $root = $self->get_root_container;
    }
    else {
        $root = $self;
        while (!$root->isa('Bread::Board::Container')) {
            $root = $root->parent;
        }
    }

    my @path = grep { $_ } split /\// => $path;

    if ($path[0] eq '..') {
        my $c = $root;
        do {
            shift @path;
            $c = $c->parent
                 || confess "Expected parent for " . $c->name . " but found none";
        } while (defined $path[0] && $path[0] eq '..' && $c->has_parent);
        $root = $c;
    }

    return $root unless @path;

    my $c = $root;
    while (my $h = shift @path) {
        $c = _get_container_or_service($c, $h);
    }
    if (!$self->isa('Bread::Board::Service::Alias')) {
        my %seen;
        while ($c->isa('Bread::Board::Service::Alias')) {
            $c = $c->aliased_from;
            confess "Cycle detected in aliases" if exists $seen{$c};
            $seen{$c}++;
        }
    }
    return $c;
}

sub _get_container_or_service {
    my ($c, $name) = @_;

    (blessed $c)
        || confess "Expected object, got $c";

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
        if ($c->name eq $name) {
            warn "Traversing into the current service ($name) is deprecated."
               . " You should remove the $name component from the path.";
            return $c;
        }
    }
    elsif ($c->isa('Bread::Board::Container')) {
        if ($c->name eq $name) {
            warn "Traversing into the current container ($name) is deprecated;"
               . " you should remove the $name component from the path";
            return $c;
        }
        return $c->get_sub_container($name) if $c->has_sub_container($name);
        return $c->get_service($name)       if $c->has_service($name);
    }

    confess "Could not find container or service for $name in " . $c->name;
}

no Moose::Role; 1;

__END__

=pod

=encoding UTF-8

=head1 NAME

Bread::Board::Traversable - role for traversing a container service tree

=head1 VERSION

version 0.35

=head1 SYNOPSIS

  my $service = $container->fetch('/some/service/path');

  my $root = $service->get_root_container;

=head1 DESCRIPTION

This role provides the basic functionality to traverse a container /
service tree. Instances of classes consuming this role will get a
parent-child relationship between them.

=head1 ATTRIBUTES

=head2 C<parent>

Weak ref to another L<Bread::Board::Traversable> object, read/write
accessor (although you should probably not change this value directly
in normal code).

=head1 METHODS

=head2 C<has_parent>

Predicate for the L</parent> attribute, true if a parent has been set.

=head2 C<detach_from_parent>

Clearer for the L</parent> attribute, you should probably not call
this method in normal code.

=head2 C<get_root_container>

Returns the farthest ancestor of the invocant, i.e. the top-most
container this object is a part of.

=head2 C<fetch>

  my $service = $this->fetch('/absolute/path');
  my $service = $this->fetch('relative/path');
  my $service = $this->fetch('../relative/path');

Given a (relative or absolute) path to a service or container, this
method walks the tree and returns the L<Bread::Board::Service> or
L<Bread::Board::Container> instance for that path. Dies if no object
can be found for the given
path.

L<Aliases|Bread::Board::Service::Alias> are resolved in this call, by
calling L<< C<aliased_from>|Bread::Board::Service::Alias/aliased_from
>> until we get an actual service.

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
