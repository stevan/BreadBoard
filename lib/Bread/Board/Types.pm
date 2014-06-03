package Bread::Board::Types;
BEGIN {
  $Bread::Board::Types::AUTHORITY = 'cpan:STEVAN';
}
$Bread::Board::Types::VERSION = '0.32';
use Moose::Util::TypeConstraints;

use Scalar::Util qw(blessed);

use Bread::Board::Service;
use Bread::Board::Dependency;

## for Bread::Board::Container

class_type 'Bread::Board::Container';
class_type 'Bread::Board::Container::Parameterized';

subtype 'Bread::Board::Container::SubContainerList'
    => as 'HashRef[Bread::Board::Container|Bread::Board::Container::Parameterized]';

coerce 'Bread::Board::Container::SubContainerList'
    => from 'ArrayRef[Bread::Board::Container]'
        => via { +{ map { $_->name => $_ } @$_ } };

subtype 'Bread::Board::Container::ServiceList'
    => as 'HashRef[Bread::Board::Service]';

coerce 'Bread::Board::Container::ServiceList'
    => from 'ArrayRef[Bread::Board::Service]'
        => via { +{ map { $_->name => $_ } @$_ } };

## for Bread::Board::Service::WithDependencies ...

subtype 'Bread::Board::Service::Dependencies'
    => as 'HashRef[Bread::Board::Dependency]';

my $ANON_INDEX = 1;
sub _coerce_to_dependency {
    my ($dep) = @_;

    if (!blessed($dep)) {
        if (ref $dep eq 'HASH') {
            my ($service_path)   = keys %$dep;
            my ($service_params) = values %$dep;
            $dep = Bread::Board::Dependency->new(
                service_path   => $service_path,
                service_params => $service_params
            );
        }
        elsif (ref $dep eq 'ARRAY') {
            require Bread::Board::BlockInjection;
            my $name = '_ANON_COERCE_' . $ANON_INDEX++ . '_';
            my @deps = map { _coerce_to_dependency($_) } @$dep;
            my @dep_names = map { "${name}DEP_$_" } 0..$#deps;
            $dep = Bread::Board::Dependency->new(
                service_name => $name,
                service      => Bread::Board::BlockInjection->new(
                    name         => $name,
                    dependencies => { map { $dep_names[$_] => $deps[$_]->[1] }
                                          0..$#deps },
                    block        => sub {
                        my ($s) = @_;
                        return [ map { $s->param($_) } @dep_names ];
                    },
                ),
            );
            $dep->service->parent($dep);
        }
        else {
            $dep = Bread::Board::Dependency->new(service_path => $dep);
        }
    }

    if ($dep->isa('Bread::Board::Dependency')) {
        return [$dep->service_name => $dep];
    }
    else {
        return [$dep->name => Bread::Board::Dependency->new(service => $dep)];
    }
}

coerce 'Bread::Board::Service::Dependencies'
    => from 'HashRef[Bread::Board::Service | Bread::Board::Dependency | Str | HashRef | ArrayRef]'
        => via {
            +{
                map { $_ => _coerce_to_dependency($_[0]->{$_})->[1] }
                    keys %{$_[0]}
            }
        }
    => from 'ArrayRef[Bread::Board::Service | Bread::Board::Dependency | Str | HashRef]'
        => via {
            +{
                map { @{ _coerce_to_dependency($_) } } @{$_[0]}
            }
        };

## for Bread::Board::Service::WithParameters ...

subtype 'Bread::Board::Service::Parameters' => as 'HashRef';

coerce 'Bread::Board::Service::Parameters'
    => from 'ArrayRef'
        => via { +{ map { $_ => { optional => 0 } } @$_ } };

no Moose::Util::TypeConstraints; 1;

__END__

=pod

=encoding UTF-8

=head1 NAME

Bread::Board::Types

=head1 VERSION

version 0.32

=head1 DESCRIPTION

=head1 BUGS

All complex software has bugs lurking in it, and this module is no
exception. If you find a bug please either email me, or add the bug
to cpan-RT.

=head1 AUTHOR

Stevan Little <stevan@iinteractive.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2014 by Infinity Interactive.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
