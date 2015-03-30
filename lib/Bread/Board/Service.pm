package Bread::Board::Service;
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

=head1 DESCRIPTION

This role is the basis for all services in L<Bread::Board>. It
provides (or requires the implementation of) the minimum necessary
building blocks: creating an instance, setting/getting parameters,
instance lifecycle.

=head1 METHODS

=over 4

=item B<name>

Read/write string, required. Every service needs a name, by which it
can be referenced when L<fetching it|Bread::Board::Traversable/fetch>.

=item B<is_locked>

Boolean, defaults to false. Used during L<dependency
resolution|Bread::Board::Service::WithDependencies/resolve_dependencies>
to detect loops.

=item B<lock>

Locks the service; you should never need to call this method in normal
code.

=item B<unlock>

Unlocks the service; you should never need to call this method in
normal code.

=item B<lifecycle>

  $service->lifecycle('Singleton');

Read/write string; it should be either a partial class name under the
C<Bread::Board::LifeCycle::> namespace (like C<Singleton> for
C<Bread::Board::LifeCycle::Singleton>) or a full class name prefixed
with C<+> (like C<+My::Special::Lifecycle>). The name is expected to
refer to a loadable I<role>, which will be applied to the service
instance.

=item B<get>

  my $value = $service->get();

This method I<must> be implemented by the consuming class. It's
expected to instantiate whatever object or value this service should
resolve to.

=item B<init_params>

Builder for the service parameters, defaults to returning an empty
hashref.

=item B<param>

  my @param_names = $service->param();
  my $param_value = $service->param($param_name);
  $service->param($name1=>$value1,$name2=>$value2);

Getter/setter for the service parameters; notice that calling thes
method with no arguments returns the list of parameter names.

=item B<clone_and_inherit_params>

When declaring a service using the L<< C<service> helper
function|Bread::Board/service >>, if the name you use starts with a
C<'+'>, the service definition will extend an existing service with
the given name (without the C<'+'>). This method implements the
extension semantics: the C<dependencies> and C<parameters> options
will be merged with the existing values, rather than overridden.

=back

=head1 BUGS

All complex software has bugs lurking in it, and this module is no
exception. If you find a bug please either email me, or add the bug
to cpan-RT.

=cut
