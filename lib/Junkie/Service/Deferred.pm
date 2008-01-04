package Junkie::Service::Deferred;
use Moose ();

our $VERSION = '0.01';

use overload '%{}' => sub { 
                    return $_[0] if (caller)[0] eq 'Junkie::Service::Deferred';
                    $_[0] = $_[0]->{service}->get; 
                    $_[0] 
              },
             '@{}' => sub { $_[0] = $_[0]->{service}->get; $_[0] },
             '${}' => sub { $_[0] = $_[0]->{service}->get; $_[0] },             
             '&{}' => sub { $_[0] = $_[0]->{service}->get; $_[0] },
              nomethod => sub {
                    $_[0] = $_[0]->{service}->get;
                    return overload::StrVal($_[0]) if ($_[3] eq '""' && !overload::Method($_[0], $_[3]));
                    if (my $func = overload::Method($_[0], $_[3])) {
                        return $_[0]->$func($_[1], $_[2]);
                    }
                    Carp::confess "Could not find a method for overloaded '$_[3]' operator";
              };             

sub new { 
    my ($class, %params) = @_;
    (Scalar::Util::blessed($params{service}) && $params{service}->does('Junkie::Service'))
        || Carp::confess "You can only defer Junkie::Service instances";
    bless {
        service => $params{service}
    } => $class; 
}

sub can { 
    $_[0] = $_[0]->{service}->get;
    (shift)->can(shift);
}

sub isa { 
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