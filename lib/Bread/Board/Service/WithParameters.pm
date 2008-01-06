package Bread::Board::Service::WithParameters;
use Moose::Role;
use MooseX::AttributeHelpers;
use MooseX::Params::Validate;

use Bread::Board::Types;

our $VERSION = '0.01';

with 'Bread::Board::Service';

has 'parameters' => (
    metaclass => 'Collection::Hash',
    is        => 'ro',
    isa       => 'Bread::Board::Service::Parameters',
    lazy      => 1,
    coerce    => 1,
    default   => sub { +{} },
    provides  => {
        'empty'  => 'has_parameters',
    }
);

sub check_parameters {
    my $self = shift;
    return validate(\@_, %{$self->parameters})
        if $self->has_parameters;
    return ();
}

before 'get' => sub {
    my $self = shift;
    $self->params({ %{ $self->params }, $self->check_parameters(@_) });    
};

1;

__END__

=pod

=head1 NAME

Bread::Board::Service::ConstructorInjection - A fix for what ails you

=head1 SYNOPSIS

=head1 DESCRIPTION

=cut