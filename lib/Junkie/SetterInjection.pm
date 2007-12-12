package Junkie::SetterInjection;
use Moose;

use Junkie::Types;

our $VERSION = '0.01';

with 'Junkie::Service::WithClass',
     'Junkie::Service::WithDependencies',
     'Junkie::Service::WithParameters';

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

Junkie::Service::ConstructorInjection - A fix for what ails you

=head1 SYNOPSIS

=head1 DESCRIPTION

=cut