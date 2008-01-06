package Bread::Board::Traversable;
use Moose::Role;

use Sub::Current;

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

has 'parent' => (
    is          => 'rw',
    isa         => 'Bread::Board::Traversable',
    is_weak_ref => 1,
    clearer     => 'detach_from_parent',
    predicate   => 'has_parent',
);

sub get_root_container {
    sub {
        my $c = shift;
        return $c unless $c->has_parent;
        return ROUTINE->($c->parent)
    }->(@_);
}

sub fetch {
    my ($self, $path) = @_;

    my $root = $path =~ /^\// ? $self->get_root_container : $self;
    my @path = grep { $_ } split /\// => $path;

    ($root, @path) = sub {
        my ($c, $h, @t) = @_;
        return @_ if not(defined($h)) || $h ne '..' || not($c->has_parent);
        return ROUTINE->($c->parent, @t);
    }->($root, @path) if $path[0] eq '..';
    
    return $root unless @path;

    my $get_container_or_service = sub {
        my ($c, $name) = @_;
        if ($c->does('Bread::Board::Service::WithDependencies')) {
            return $c->get_dependency($name) if $c->has_dependency($name);
            confess "Could not find dependency ($name) from service " . $c->name;
        }
        return $c->get_sub_container($name) if $c->has_sub_container($name);
        return $c->get_service($name)       if $c->has_service($name);
        confess "Could not find container or service for $name";
    };

    return sub {
        my ($c, $h, @t) = @_;
        return $c unless $h;
        return ROUTINE->($get_container_or_service->($c, $h), @t);
    }->($root, @path);
}

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