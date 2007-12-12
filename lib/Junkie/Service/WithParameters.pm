package Junkie::Service::WithParameters;
use Moose::Role;
use MooseX::AttributeHelpers;
use MooseX::Params::Validate;

use Junkie::Types;

our $VERSION = '0.01';

with 'Junkie::Service';

has 'parameters' => (
    metaclass => 'Collection::Hash',
    is        => 'ro',
    isa       => 'Junkie::Service::Parameters',
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

Junkie::Service::ConstructorInjection - A fix for what ails you

=head1 SYNOPSIS

=head1 DESCRIPTION

=cut