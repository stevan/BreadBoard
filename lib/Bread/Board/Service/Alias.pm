package Bread::Board::Service::Alias;
use Moose;

use Try::Tiny;

our $VERSION   = '0.18';
our $AUTHORITY = 'cpan:STEVAN';

has aliased_from_path => (
    is  => 'ro',
    isa => 'Str',
);

has aliased_from => (
    is      => 'ro',
    does    => 'Bread::Board::Service',
    lazy    => 1,
    builder => '_build_aliased_from',
    handles => ['get'], # is this sufficient?
);

has _seen => (
    is  => 'rw',
    isa => 'Bool',
);

with 'Bread::Board::Service';

sub _build_aliased_from {
    my $self = shift;

    my $path = $self->aliased_from_path;
    confess "Can't create an alias service without a service to alias from"
        unless $path;

    return try {
        $self->fetch($path);
    }
    catch {
        die "While resolving alias " . $self->name . ": $_";
    };
}

around get => sub {
    my $orig = shift;
    my $self = shift;

    confess "Cycle detected in aliases"
        if $self->_seen;

    $self->_seen(1);
    try {
        $self->$orig(@_);
    }
    catch {
        die $_;
    }
    finally {
        $self->_seen(0);
    };
};

__PACKAGE__->meta->make_immutable;

no Moose; 1;

__END__
