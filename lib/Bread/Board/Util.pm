package Bread::Board::Util;
use v5.16;
use warnings;

use Carp 'confess';
use Scalar::Util 'blessed';

use Sub::Exporter -setup => {
    exports => [qw[
        convert_array_to_name_map
        coerce_key_from_array_to_name_map
        coerce_dependencies
    ]]
};

use Bread::Board::Service;
use Bread::Board::Dependency;

sub convert_array_to_name_map {
    +{ map { $_->name => $_ } @{ $_[0] } }
}

sub coerce_key_from_array_to_name_map {
    my ($args, $key) = @_;
    return unless exists $args->{$key};
    $args->{$key} = convert_array_to_name_map( $args->{$key} )
        if ref($args->{$key}) eq 'ARRAY';
}

sub coerce_dependencies {
    my ($args) = @_;
    return unless exists $args->{'dependencies'};
    my $dependencies = $args->{'dependencies'};
    if (ref $dependencies eq 'HASH') {
        $args->{'dependencies'} = {
            map {
                my $dep = $dependencies->{$_};
                if (!blessed($dep)) {
                    if (ref $dep) {
                        my ($service_path)   = keys %$dep;
                        my ($service_params) = values %$dep;
                        $dep = Bread::Board::Dependency->new(
                            service_path   => $service_path,
                            service_params => $service_params
                        );
                    }
                    else {
                        $dep = Bread::Board::Dependency->new(service_path => $dep);
                    }
                }
                ($_ => ($dep->isa('Bread::Board::Dependency')
                        ? $dep
                        : Bread::Board::Dependency->new(service => $dep)))
            } keys %$dependencies
        };
    } elsif (ref $dependencies eq 'ARRAY') {
        $args->{'dependencies'} = {
            map {
                my $dep = $_;
                if (!blessed($dep)) {
                    if (ref $dep) {
                        my ($service_path)   = keys %$dep;
                        my ($service_params) = values %$dep;
                        $dep = Bread::Board::Dependency->new(
                            service_path   => $service_path,
                            service_params => $service_params
                        );
                    }
                    else {
                        $dep = Bread::Board::Dependency->new(service_path => $dep);
                    }
                }
                ($dep->isa('Bread::Board::Dependency')
                    ? ($dep->service_name => $dep)
                    : ($dep->name         => Bread::Board::Dependency->new(service => $dep)))
            } @$dependencies
        };
    }
}

=pod

subtype 'Bread::Board::Service::Parameters' => as 'HashRef';

coerce 'Bread::Board::Service::Parameters'
    => from 'ArrayRef'
        => via { +{ map { $_ => { optional => 0 } } @$_ } };

=cut

1;

__END__

=pod

=head1 DESCRIPTION

=head1 BUGS

All complex software has bugs lurking in it, and this module is no
exception. If you find a bug please either email me, or add the bug
to cpan-RT.

=cut
