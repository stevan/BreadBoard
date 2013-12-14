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
        Module::Runtime::use_package_optimistically($lifecycle_role);
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

=head1 METHODS

=over 4

=item B<name>

=item B<is_locked>

=item B<lock>

=item B<unlock>

=item B<lifecycle>

=item B<get>

=item B<init_params>

=item B<param>

=item B<clone_and_inherit_params>

=back

=head1 BUGS

All complex software has bugs lurking in it, and this module is no
exception. If you find a bug please either email me, or add the bug
to cpan-RT.

=cut
