package Bread::Board::Service;
use v5.16;
use warnings;
use mop;

use MooseX::Params::Validate qw(validated_hash);

role WithParameters with Bread::Board::Service {

    has $parameters is ro, lazy = $_->_build_parameters;

    has $_parameter_keys_to_remove is rw;

    method has_parameters { scalar keys %$parameters }

    method _clear_parameter_keys_to_remove { undef   $_parameter_keys_to_remove }
    method _has_parameter_keys_to_remove   { defined $_parameter_keys_to_remove }

    method prepare_parameters {
        my %params = $self->check_parameters(@_);
        $self->_parameter_keys_to_remove( [ keys %params ] );
        $self->params({ %{ $self->params }, %params });
    }

    method clean_parameters {
        return unless $self->_has_parameter_keys_to_remove;
        map { $self->_clear_param( $_ ) } @{ $self->_parameter_keys_to_remove };
        $self->_clear_parameter_keys_to_remove;
    }

    method _build_parameters { +{} }

    method check_parameters {
        return validated_hash(\@_, (
            %$parameters,
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

    method has_required_parameters {
        scalar grep { ! $_->{optional} } values %$parameters;
    }

    method has_parameter_defaults {
        my $self = shift;
        scalar grep { $_->{default} } values %$parameters;
    }

}

__END__

=pod

=head1 DESCRIPTION

=head1 METHODS

=over 4

=item B<get>

=item B<parameters>

=item B<has_parameters>

=item B<has_parameter_defaults>

=item B<has_required_parameters>

=item B<check_parameters>

=back

=head1 BUGS

All complex software has bugs lurking in it, and this module is no
exception. If you find a bug please either email me, or add the bug
to cpan-RT.

=cut
