package Bread::Board::Literal;
use Moose;

our $VERSION = '0.01';

with 'Bread::Board::Service';

has 'value' => (
    is       => 'rw',
    isa      => 'Defined',
    required => 1,
);

sub get { (shift)->value }

1;

__END__

=pod

=head1 NAME

Bread::Board::Service::ConstructorInjection - A fix for what ails you

=head1 SYNOPSIS

=head1 DESCRIPTION

=cut