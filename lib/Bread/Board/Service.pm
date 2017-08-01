package Bread::Board::Service;
our $AUTHORITY = 'cpan:STEVAN';
# ABSTRACT: Base service role
$Bread::Board::Service::VERSION = '0.35';
use Moose::Role;
use Module::Runtime ();

use Moose::Util::TypeConstraints 'find_type_constraint';

with 'Bread::Board::Traversable';

has 'name' => (
    is       => 'rw',
    isa      => 'Str',
    required => 1
);

has 'params' => (
    traits   => [ 'Hash' ],
    is       => 'rw',
    isa      => 'HashRef',
    lazy     => 1,
    builder  => 'init_params',
    clearer  => 'clear_params',
    handles  => {
        get_param      => 'get',
        get_param_keys => 'keys',
        _clear_param   => 'delete',
        _set_param     => 'set',
    }
);

has 'is_locked' => (
    is      => 'rw',
    isa     => 'Bool',
    default => sub { 0 }
);

has 'lifecycle' => (
    is      => 'rw',
    isa     => 'Str',
    trigger => sub {
        my ($self, $lifecycle) = @_;
        if ($self->does('Bread::Board::LifeCycle')) {
            my $base = (Class::MOP::class_of($self)->superclasses)[0];
            Class::MOP::class_of($base)->rebless_instance_back($self);
            return if $lifecycle eq 'Null';
        }

        my $lifecycle_role = $lifecycle =~ /^\+/
                 ? substr($lifecycle, 1)
                 : "Bread::Board::LifeCycle::${lifecycle}";
        Module::Runtime::require_module($lifecycle_role);
        Class::MOP::class_of($lifecycle_role)->apply($self);
    }
);

sub init_params { +{} }
sub param {
    my $self = shift;
    return $self->get_param_keys     if scalar @_ == 0;
    return $self->get_param( $_[0] ) if scalar @_ == 1;
    ((scalar @_ % 2) == 0)
        || confess "parameter assignment must be an even numbered list";
    my %new = @_;
    while (my ($key, $value) = each %new) {
        $self->set_param( $key => $value );
    }
    return;
}

{
    my %mergeable_params = (
        dependencies => {
            interface  => 'Bread::Board::Service::WithDependencies',
            constraint => 'Bread::Board::Service::Dependencies',
        },
        parameters => {
            interface  => 'Bread::Board::Service::WithParameters',
            constraint => 'Bread::Board::Service::Parameters',
        },
    );

    sub clone_and_inherit_params {
        my ($self, %params) = @_;

        confess "Changing a service's class is not possible when inheriting"
            unless $params{service_class} eq blessed $self;

        for my $p (keys %mergeable_params) {
            if (exists $params{$p}) {
                if ($self->does($mergeable_params{$p}->{interface})) {
                    my $type = find_type_constraint $mergeable_params{$p}->{constraint};

                    my $val = $type->assert_coerce($params{$p});

                    $params{$p} = {
                        %{ $self->$p },
                        %{ $val },
                    };
                }
                else {
                    confess "Trying to add $p to a service not supporting them";
                }
            }
        }

        $self->clone(%params);
    }
}

requires 'get';

sub lock   { (shift)->is_locked(1) }
sub unlock { (shift)->is_locked(0) }

no Moose::Util::TypeConstraints; no Moose::Role; 1;

__END__

=pod

=encoding UTF-8

=head1 NAME

Bread::Board::Service - Base service role

=head1 VERSION

version 0.35

=head1 DESCRIPTION

This role is the basis for all services in L<Bread::Board>. It
provides (or requires the implementation of) the minimum necessary
building blocks: creating an instance, setting/getting parameters,
instance lifecycle.

=head1 ATTRIBUTES

=head2 C<name>

Read/write string, required. Every service needs a name, by which it
can be referenced when L<fetching it|Bread::Board::Traversable/fetch>.

=head2 C<is_locked>

Boolean, defaults to false. Used during L<dependency
resolution|Bread::Board::Service::WithDependencies/resolve_dependencies>
to detect loops.

=head2 C<lifecycle>

  $service->lifecycle('Singleton');

Read/write string; it should be either a partial class name under the
C<Bread::Board::LifeCycle::> namespace (like C<Singleton> for
C<Bread::Board::LifeCycle::Singleton>) or a full class name prefixed
with C<+> (like C<+My::Special::Lifecycle>). The name is expected to
refer to a loadable I<role>, which will be applied to the service
instance.

=head1 METHODS

=head2 C<lock>

Locks the service; you should never need to call this method in normal
code.

=head2 C<unlock>

Unlocks the service; you should never need to call this method in
normal code.

=head2 C<get>

  my $value = $service->get();

This method I<must> be implemented by the consuming class. It's
expected to instantiate whatever object or value this service should
resolve to.

=head2 C<init_params>

Builder for the service parameters, defaults to returning an empty
hashref.

=head2 C<clear_params>

Clearer of the service parameters.

=head2 C<param>

  my @param_names = $service->param();
  my $param_value = $service->param($param_name);
  $service->param($name1=>$value1,$name2=>$value2);

Getter/setter for the service parameters; notice that calling this
method with no arguments returns the list of parameter names.

I<Please note>: these are not the same as the L<parameters for a
parametric service|Bread::Board::Service::WithParameters> (although
those will be copied here before C<get> is called), nor are they the
same thing as L<dependencies|Bread::Board::Service::WithDependencies>
(although the resolved dependencies will be copied here before C<get>
is called).

=head2 C<clone_and_inherit_params>

When declaring a service using the L<< C<service> helper
function|Bread::Board/service >>, if the name you use starts with a
C<'+'>, the service definition will extend an existing service with
the given name (without the C<'+'>). This method implements the
extension semantics: the C<dependencies> and C<parameters> options
will be merged with the existing values, rather than overridden.

=head1 AUTHOR

Stevan Little <stevan@iinteractive.com>

=head1 BUGS

Please report any bugs or feature requests on the bugtracker website
https://github.com/stevan/BreadBoard/issues

When submitting a bug or request, please include a test-file or a
patch to an existing test-file that illustrates the bug or desired
feature.

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2017, 2016, 2015, 2014, 2013, 2011, 2009 by Infinity Interactive.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
