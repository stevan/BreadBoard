package Bread::Board::Service::Deferred;
use Moose ();

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

use overload 
    # cover your basic operatins ...
    'bool' => sub { 1 },
    '""'   => sub {
        $_[0] = (eval { $_[0]->{service}->instace } || $_[0]->{service}->get);
        if (my $func = overload::Method($_[0], '""')) {
            return $_[0]->$func();            
        }
        return overload::StrVal($_[0]); 
    },
    
    # cover your basic dereferncers
    '%{}' => sub { 
        return $_[0] if (caller)[0] eq 'Bread::Board::Service::Deferred';
        $_[0] = (eval { $_[0]->{service}->instace } || $_[0]->{service}->get); 
        $_[0] 
    },
    '@{}' => sub { $_[0] = (eval { $_[0]->{service}->instace } || $_[0]->{service}->get); $_[0] },
    '${}' => sub { $_[0] = (eval { $_[0]->{service}->instace } || $_[0]->{service}->get); $_[0] },             
    '&{}' => sub { $_[0] = (eval { $_[0]->{service}->instace } || $_[0]->{service}->get); $_[0] },
    
    ## and as a last ditch resort ...
    nomethod => sub {
        $_[0] = (eval { $_[0]->{service}->instace } || $_[0]->{service}->get);
        return overload::StrVal($_[0]) if $_[3] eq '""' && !overload::Method($_[0], $_[3]);
        if (my $func = overload::Method($_[0], $_[3])) {
            return $_[0]->$func($_[1]);
        }
        Carp::confess "Could not find a method for overloaded '$_[3]' operator";
    }
;             

sub new { 
    my ($class, %params) = @_;
    (Scalar::Util::blessed($params{service}) && $params{service}->does('Bread::Board::Service'))
        || Carp::confess "You can only defer Bread::Board::Service instances";
    bless {
        service => $params{service}
    } => $class; 
}

sub can { 
    if ($_[0]->{service}->can('class')) {
        my $class = $_[0]->{service}->class;
        return $class->can($_[1]);
    }    
    $_[0] = (eval { $_[0]->{service}->instace } || $_[0]->{service}->get);
    (shift)->can(shift);
}

sub isa { 
    if ($_[0]->{service}->can('class')) {
        my $class = $_[0]->{service}->class;
        return 1 if $class eq $_[1];
        return $class->isa($_[1]);
    }
    $_[0] = (eval { $_[0]->{service}->instace } || $_[0]->{service}->get);
    (shift)->isa(shift);
}

sub DESTROY { (shift)->{service} = undef }

sub AUTOLOAD {
    my ($subname) = our $AUTOLOAD =~ /([^:]+)$/;
    $_[0] = (eval { $_[0]->{service}->instace } || $_[0]->{service}->get);
    my $func = $_[0]->can($subname);
    (ref($func) eq 'CODE') 
        || Carp::confess "You cannot call '$subname'";
    goto &$func;
}

1;

__END__

=pod

=head1 NAME

Bread::Board::

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 METHODS

=over 4

=item B<>

=back

=head1 BUGS

All complex software has bugs lurking in it, and this module is no
exception. If you find a bug please either email me, or add the bug
to cpan-RT.

=head1 AUTHOR

Stevan Little E<lt>stevan@iinteractive.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright 2007-2008 by Infinity Interactive, Inc.

L<http://www.iinteractive.com>

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut