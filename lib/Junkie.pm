package Junkie;
use Moose;

use Junkie::Types;

use Junkie::ConstructorInjection;
use Junkie::SetterInjection;
use Junkie::BlockInjection;
use Junkie::Literal;

use Junkie::Container;
use Junkie::Dependency;

use Junkie::LifeCycle::Singleton;

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

my @exports = qw[
    container
    service
    as
    depends_on
];

Sub::Exporter::setup_exporter({
    exports => \@exports,
    groups  => { default => \@exports }
});

sub as (&) { $_[0] }

our $CC;

sub set_root_container {
    (defined $CC && confess "Cannot set the root container, CC is already defined $CC");
    $CC = shift;
}

sub container ($;$) {
    my ($name, $body) = @_;
    my $c = Junkie::Container->new(name => $name);
    if (defined $CC) {
        $CC->add_sub_container($c);
    }
    if (defined $body) {
        local $_  = $c;
        local $CC = $c;
        $body->($c);
    }
    return $c;
}

sub service ($@) {
    my $name = shift;
    my $s;
    if (scalar @_ == 1) {
        $s = Junkie::Literal->new(name => $name, value => $_[0]);
    }
    elsif (scalar(@_) % 2 == 0) {
        my %params = @_;
        my $type   = $params{type} || (exists $params{block} ? 'Block' : 'Constructor');
        if (exists $params{dependencies} && ref $params{dependencies} eq 'ARRAY') {
            # NOTE:
            # allow for auto-wiring the dependencies here
            # which just makes life a lot easier in the
            # common case
            # - SL
            $params{dependencies} = {
                map {
                    # we need to strip off our ../../
                    # which is added below in &depends_on
                    my ($name) = ($_->service_path =~ /\.\.\/\.\.\/(.*)/);
                    # but don't let them do anything silly
                    # cause a name with a / in it is surely
                    # wrong.
                    confess "Cannot have a name with / in it, your abusing the auto-wiring there kiddo"
                        if $name =~ /\//;
                    ($name => $_)
                } @{$params{dependencies}}
            };
        }
        $s =  "Junkie::${type}Injection"->new(name => $name, %params);
    }
    else {
        confess "I don't understand @_";
    }
    $CC->add_service($s);
}


sub depends_on ($) {
    my $path = shift;
    Junkie::Dependency->new(service_path => ('../../' . $path));
}

1;

__END__

=pod

=head1 NAME

Junkie - A fix for what ails you

=head1 SYNOPSIS

  use Junkie;

  my $c = container 'MyApp' => as {

      service 'log_file_name' => "logfile.log";

      service 'logger' => (
          class        => 'FileLogger',
          lifecycle    => 'Singleton',
          dependencies => {
              log_file => depends_on('log_file_name'),
          }
      );

      service 'application' => (
          class        => 'MyApplication',
          dependencies => [
              # this will auto-wire the depenency 
              # for you with the name "logger" 
              depends_on('logger'),
          ]
      );

  };

  $c->fetch('application')->run;

=head1 DESCRIPTION

=cut