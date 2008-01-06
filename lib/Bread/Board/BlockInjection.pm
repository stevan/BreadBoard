package Bread::Board::BlockInjection;
use Moose;

our $VERSION = '0.01';

with 'Bread::Board::Service::WithDependencies',
     'Bread::Board::Service::WithParameters';

has 'block' => (
    is       => 'rw',
    isa      => 'CodeRef',
    required => 1,
);

has 'class' => (
    is        => 'rw',
    isa       => 'Str',
    predicate => 'has_class'
);

sub get { 
    my $self = shift;
    Class::MOP::load_class($self->class) if $self->has_class;
    $self->block->($self) 
}

1;

__END__

=pod

=head1 NAME

Bread::Board::Service::ConstructorInjection - A fix for what ails you

=head1 SYNOPSIS

=head1 DESCRIPTION

=cut