package Bread::Board::Container::FromParameterized;
use Moose;

extends 'Bread::Board::Container';

has '+parent' => (
    weak_ref => 0,
);

__PACKAGE__->meta->make_immutable;

no Moose; 1;
