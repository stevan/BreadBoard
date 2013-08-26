package Bread::Board;
use v5.16;
use warnings;
use mop;

use Carp 'confess';
use Scalar::Util 'blessed';

role Traversable {
    has $parent is rw, weak_ref;

    method detach_from_parent { undef $parent }

    method has_parent { defined $parent }

    method get_root_container {
        my $c = $self;
        while ($c->has_parent) {
            $c = $c->parent;
        }
        return $c;
    }

    method fetch ($path) {

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
            $c = $self->_get_container_or_service($c, $h);
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

    method _get_container_or_service ($c, $name) {

        (blessed $c)
            || confess "Expected object, got $c";

        if ($c->isa('Bread::Board::Dependency')) {
            # make sure to evaluate this from the parent
            return $self->_get_container_or_service($c->parent->parent, $name);
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
}

__END__

=pod

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

=cut
