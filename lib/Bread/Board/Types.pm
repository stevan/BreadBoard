package Bread::Board::Types;
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

=head1 DESCRIPTION

This package defines types and coercions for L<Bread::Board>.

=head1 TYPES

=head2 C<Bread::Board::Container::SubContainerList>

A hashref mapping strings to instances of L<Bread::Board::Container>
or L<Bread::Board::Container::Parameterized>.

Can be coerced from an arrayref of containers: the keys will be the
containers' names.

=head2 C<Bread::Board::Container::ServiceList>

A hashref mapping strings to instances of L<Bread::Board::Service>.

Can be coerced from an arrayref of services: the keys will be the
services' names.

=head2 C<Bread::Board::Service::Dependencies>

Hashref mapping strings to instances of L<Bread::Board::Dependency>.

The values of the hashref can be coerced in several different ways:

=begin :list

= a string

will be interpreted as the L<< C<service_path>|Bread::Board::Dependency/service_path >>

= a hashref with a single key

the key will be interpreted as a L<<
C<service_path>|Bread::Board::Dependency/service_path >>, and the
value as a hashref for L<<
C<service_params>|Bread::Board::Dependency/service_params >>

= an arrayref

each element will be interpreted as a dependency (possibly through all
the coercions listed here); see below for an example

= a L<service|Bread::Board::Service> object

will be interpreted as a dependency on that service

= a L<dependency|Bread::Board::Dependency> object

will be taken as-is

=end :list

Instead of a hashref of any of the above things, you can use an
arrayref: it will be coerced to hashref, using the (coerced)
dependencies' names as keys.

=head3 Examples

   service foo => (
     class => 'Foo',
     dependencies => {
       { bar => { attribute => 12 } },
     },
   );

The service C<foo> depends on the parameterized service C<bar>, and
C<bar> will be instantiated passing the hashref C<< { attribute => 12
} >> to its L<< C<get>|Bread::Board::Service::WithParameters/get >>
method.

   service foo => (
     class => 'Foo',
     dependencies => {
       things => [ 'bar', 'baz' ],
     },
   );

The service C<foo> depends on the services C<bar> and C<baz>, and when
instantiating C<foo>, its constructor will receive something like C<<
things => [ $instance_of_bar, $instance_of_baz ] >>.


   service foo => (
     class => 'Foo',
     dependencies => {
       things => [
         { bar => { attribute => 12 } },
         { bar => { attribute => 27 } },
       ],
     },
   );

You can mix&match the coercions! This C<foo> will get two different
instances of C<bar> in its C<things> attribute, each C<bar>
instantiated with a different value.

=head2 C<Bread::Board::Service::Parameters>

Hashref mapping strings to L<MooseX::Params::Validate> specifications.

Can be coerced from an arrayref of strings:

  [qw(a b c)]

becomes:

  {
    a => { optional => 0 },
    b => { optional => 0 },
    c => { optional => 0 },
  }
