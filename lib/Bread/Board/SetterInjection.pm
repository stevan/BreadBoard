package Bread::Board::SetterInjection;
use Moose;

use Bread::Board::Types;

our $VERSION = '0.01';

with 'Bread::Board::Service::WithClass',
     'Bread::Board::Service::WithDependencies',
     'Bread::Board::Service::WithParameters';

sub get {
    my $self = shift;
    my $o = $self->class->new;
    $o->$_($self->param($_)) foreach $self->param;
    return $o;
}

1;

__END__

=pod

=head1 NAME

Bread::Board::Service::ConstructorInjection - A fix for what ails you

=head1 SYNOPSIS

=head1 DESCRIPTION

=cut