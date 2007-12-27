package Junkie::Service::WithClass;
use Moose::Role;
use MooseX::AttributeHelpers;

use Junkie::Types;

our $VERSION = '0.01';

with 'Junkie::Service';

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

Junkie::Service::ConstructorInjection - A fix for what ails you

=head1 SYNOPSIS

=head1 DESCRIPTION

=cut