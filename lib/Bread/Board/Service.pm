package Bread::Board::Service;
use Moose::Role;

our $VERSION = '0.01';

with 'MooseX::Param',
     'Bread::Board::Traversable';

has 'name' => (
    is       => 'rw', 
    isa      => 'Str', 
    required => 1
);

has 'is_locked' => (
    is      => 'rw',
    isa     => 'Bool',
    default => sub { 0 }
);

has 'lifecycle' => (
    is      => 'rw', 
    isa     => 'Str', 
    trigger => sub {
        my ($self, $lifecycle) = @_;
        if ($self->does('Bread::Board::LifeCycle')) {
            bless $self => ($self->meta->superclasses)[0];
            return if $lifecycle eq 'Null';
        }
        ("Bread::Board::LifeCycle::${lifecycle}")->meta->apply($self);        
    }
);

requires 'get';

sub lock   { (shift)->is_locked(1) }
sub unlock { (shift)->is_locked(0) }

1;

__END__

=pod

=head1 NAME

Bread::Board::Service - A fix for what ails you

=head1 SYNOPSIS

=head1 DESCRIPTION

=cut