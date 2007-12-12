package Junkie::Service;
use Moose::Role;

our $VERSION = '0.01';

with 'MooseX::Param';

has 'name' => (
    is       => 'rw', 
    isa      => 'Str', 
    required => 1
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