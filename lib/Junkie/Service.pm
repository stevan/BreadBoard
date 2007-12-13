package Junkie::Service;
use Moose::Role;

our $VERSION = '0.01';

with 'MooseX::Param';

has 'name' => (
    is       => 'rw', 
    isa      => 'Str', 
    required => 1
);

has 'parent' => (
    is          => 'rw',
    isa         => 'Junkie::Container',
    is_weak_ref => 1,
    clearer     => 'detach_from_parent',
    predicate   => 'has_parent',
);

has 'lifecycle' => (
    is      => 'rw', 
    isa     => 'Str', 
    trigger => sub {
        my ($self, $lifecycle) = @_;
        if ($self->does('Junkie::LifeCycle')) {
            bless $self => ($self->meta->superclasses)[0];
            return if $lifecycle eq 'Null';
        }
        ("Junkie::LifeCycle::${lifecycle}")->meta->apply($self);        
    }
);

requires 'get';

1;

__END__

=pod

=head1 NAME

Junkie::Service - A fix for what ails you

=head1 SYNOPSIS

=head1 DESCRIPTION

=cut