package Bread::Board::ConstructorInjection;
use Moose;

use Bread::Board::Types;

our $VERSION = '0.01';

with 'Bread::Board::Service::WithClass',
     'Bread::Board::Service::WithDependencies',
     'Bread::Board::Service::WithParameters';

sub get {
    my $self = shift;
    $self->class->new( %{ $self->params } );
}

1;

__END__

=pod

=head1 NAME

Bread::Board::Service::ConstructorInjection - A fix for what ails you

=head1 SYNOPSIS

=head1 DESCRIPTION

=cut