package Bread::Board::Service::WithClass;
use Moose::Role;
use MooseX::AttributeHelpers;

use Bread::Board::Types;

our $VERSION = '0.01';

with 'Bread::Board::Service';

has 'class' => (
    is       => 'rw',
    isa      => 'Str',
    required => 1,
);

before 'get' => sub {
    Class::MOP::load_class((shift)->class)
};

1;

__END__

=pod

=head1 NAME

Bread::Board::Service::ConstructorInjection - A fix for what ails you

=head1 SYNOPSIS

=head1 DESCRIPTION

=cut