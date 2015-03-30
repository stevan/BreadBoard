package Bread::Board::Service::WithParameters;
use Moose::Role;
use MooseX::Params::Validate qw(validated_hash);

use Bread::Board::Types;

with 'Bread::Board::Service';

has 'parameters' => (
    traits    => [ 'Hash', 'Copy' ],
    is        => 'ro',
    isa       => 'Bread::Board::Service::Parameters',
    lazy      => 1,
    coerce    => 1,
    builder   => '_build_parameters',
    handles   => {
        'has_parameters' => 'count'
    }
);

has '_parameter_keys_to_remove' => (
    is        => 'rw',
    isa       => 'ArrayRef',
    clearer   => '_clear_parameter_keys_to_remove',
    predicate => '_has_parameter_keys_to_remove',
);

before 'get' => sub {
    my $self = shift;
    my %params = $self->check_parameters(@_);
    $self->_parameter_keys_to_remove( [ keys %params ] );
    $self->params({ %{ $self->params }, %params });
};

after 'get' => sub {
    my $self = shift;
    return unless $self->_has_parameter_keys_to_remove;
    map { $self->_clear_param( $_ ) } @{ $self->_parameter_keys_to_remove };
    $self->_clear_parameter_keys_to_remove;
};

sub _build_parameters { +{} }

sub check_parameters {
    my $self = shift;
    return validated_hash(\@_, (
        %{ $self->parameters },
        # NOTE:
        # cache the parameters in a per-service
        # basis, this should be more than adequate
        # since each service can only have one set
        # of parameters at a time. If this does end
        # up breaking then we can give it a better
        # key at that point.
        # - SL
        (MX_PARAMS_VALIDATE_CACHE_KEY => Scalar::Util::refaddr($self))
    )) if $self->has_parameters;
    return ();
}

sub has_required_parameters {
    my $self = shift;
    scalar grep { ! $_->{optional} } values %{ $self->parameters };
}

sub has_parameter_defaults {
    my $self = shift;
    scalar grep { $_->{default} } values %{ $self->parameters };
}

no Moose::Role; 1;

__END__

=pod

=head1 DESCRIPTION

This is a sub-role of L<Bread::Board::Service>, for parameterized
services. These are services that will instantiate different values
depending on parameters that are passed to the C<get> method. You can
pass those parameters via the L<< C<service_params> attribute of
C<Bread::Board::Dependency>|Bread::Board::Dependency/service_params
>>, or via the L<< C<inflate> method of
C<Bread::Board::Service::Deferred::Thunk>|Bread::Board::Service::Deferred::Thunk/inflate
>>.

=head1 METHODS

=over 4

=item B<parameters>

Read-only hashref, will be passed as-is to L<<
C<MooseX::Params::Validate>'s
C<validated_hash>|MooseX::Params::Validate/validated_hash >>, so you
can use things like C<optional> and C<default> in addition to type
constraints:

  service something => (
    class => 'Thing',
    parameters => {
       type => { isa => 'Str', default => 'text' },
    },
  );

=item B<has_parameters>

Predicate for the L</parameters> attribute.

=item B<has_parameter_defaults>

Returns true if any of the L</parameters> have a C<default> value.

=item B<has_required_parameters>

Returns true if any of the L</parameters> does I<not> have C<optional>
set to true.

=item B<check_parameters>

  my %parameters = $service->check_parameters(name1=>$value1,name2=>$value2);
  my %parameters = $service->check_parameters({name1=>$value1,name2=>$value2});

If any L</parameters> are defined, this function validates its
arguments against the parameters' definitions (using
L<MooseX::Params::Validate>). It will die if the validation fails, or
return the validated parameters (including default value) if it
succeeds.

=item B<get>

I<Before> the C<get> method, arguments to C<get> are passed through
L</check_parameters> and added to the L<<
C<params>|Bread::Board::Service/params >> hashref. I<After> the C<get>
method, those keys/values will be removed. In practice, this makes all
parameters available to the actual C<get> method body.

=back

=head1 BUGS

All complex software has bugs lurking in it, and this module is no
exception. If you find a bug please either email me, or add the bug
to cpan-RT.

=cut
