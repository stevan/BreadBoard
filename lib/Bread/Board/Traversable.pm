package Bread::Board::Traversable;
use Moose::Role;

use Sub::Current;

our $VERSION = '0.01';

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