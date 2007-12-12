package Junkie::ConstructorInjection;
use Moose;

use Junkie::Types;

our $VERSION = '0.01';

with 'Junkie::Service::WithClass',
     'Junkie::Service::WithDependencies',
     'Junkie::Service::WithParameters';

sub get {
    my $self = shift;
    $self->class->new( %{ $self->params } );
}

1;

__END__

=pod

=head1 NAME

Junkie::Service::ConstructorInjection - A fix for what ails you

=head1 SYNOPSIS

=head1 DESCRIPTION

=cut