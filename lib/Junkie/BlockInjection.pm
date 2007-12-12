package Junkie::BlockInjection;
use Moose;

our $VERSION = '0.01';

with 'Junkie::Service::WithDependencies',
     'Junkie::Service::WithParameters';

has 'block' => (
    is       => 'rw',
    isa      => 'CodeRef',
    required => 1,
);

sub get { ($_[0])->block->($_[0]) }

1;

__END__

=pod

=head1 NAME

Junkie::Service::ConstructorInjection - A fix for what ails you

=head1 SYNOPSIS

=head1 DESCRIPTION

=cut