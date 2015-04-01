package Bread::Board::Service::Deferred;
use Moose ();

use overload
    # cover your basic operatins ...
    'bool' => sub { 1 },
    '""'   => sub {
        $_[0] = $_[0]->{service}->get;
        if (my $func = overload::Method($_[0], '""')) {
            return $_[0]->$func();
        }
        return overload::StrVal($_[0]);
    },
    # cover your basic dereferncers
    '%{}' => sub {
        return $_[0] if (caller)[0] eq 'Bread::Board::Service::Deferred';
        $_[0] = $_[0]->{service}->get;
        $_[0]
    },
    '@{}' => sub { $_[0] = $_[0]->{service}->get; $_[0] },
    '${}' => sub { $_[0] = $_[0]->{service}->get; $_[0] },
    '&{}' => sub { $_[0] = $_[0]->{service}->get; $_[0] },
    '*{}' => sub { $_[0] = $_[0]->{service}->get; $_[0] },
    ## and as a last ditch resort ...
    nomethod => sub {
        $_[0] = $_[0]->{service}->get;
        return overload::StrVal($_[0]) if $_[3] eq '""' && !overload::Method($_[0], $_[3]);
        if (my $func = overload::Method($_[0], $_[3])) {
            return $_[0]->$func($_[1]);
        }
        return $_[0]; # if all else fails, just return the object
    },
;

sub new {
    my ($class, %params) = @_;
    (Scalar::Util::blessed($params{service}) && $params{service}->does('Bread::Board::Service'))
        || Carp::confess "You can only defer Bread::Board::Service instances";
    bless { service => $params{service} } => $class;
}

sub meta {
    if ($_[0]->{service}->can('class')) {
        my $class = $_[0]->{service}->class;
        return $class->meta;
    }
    $_[0] = $_[0]->{service}->get;
    (shift)->meta;
}

sub can {
    if ($_[0]->{service}->can('class')) {
        my $class = $_[0]->{service}->class;
        return $class->can($_[1]);
    }
    $_[0] = $_[0]->{service}->get;
    (shift)->can(shift);
}

sub isa {
    if ($_[0]->{service}->can('class')) {
        my $class = $_[0]->{service}->class;
        return 1 if $class eq $_[1];
        return $class->isa($_[1]);
    }
    $_[0] = $_[0]->{service}->get;
    (shift)->isa(shift);
}

sub DESTROY { (shift)->{service} = undef }

sub AUTOLOAD {
    my ($subname) = our $AUTOLOAD =~ /([^:]+)$/;
    $_[0] = $_[0]->{service}->get;
    my $func = $_[0]->can($subname);
    (ref($func) eq 'CODE')
        || Carp::confess "You cannot call '$subname'";
    goto &$func;
}

1;

__END__

=head1 DESCRIPTION

Class for proxy objects used when L<resolving circular
dependencies|Bread::Board::Service::WithDependencies/resolve_dependencies>.

This class uses a few nasty tricks: replacing C<$_[0]>, using
C<AUTOLOAD>, overriding C<isa> C<meta> and C<can>, heavy operator
overloading... you should probably not take inspiration from this code
unless you really know what you're doing.

In practice, a variable containing an instance of
C<Bread::Board::Service::Deferred> will have its value changed to the
actual value instantiated by the service at the first opportunity, and
you should not notice that this class was ever there.

=for Pod::Coverage can isa meta new
