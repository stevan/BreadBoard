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

sub container ($$) {
    my ($name, $body) = @_;
    my $c = Junkie::Container->new(name => $name);
    if (defined $CC) {
        $CC->add_sub_container($c);
    }
    {
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
      
      service 'log_file' => "logfile.log";
      
      service 'logger' => (
          class        => 'FileLogger',
          lifecycle    => 'Singleton',
          dependencies => {
              log_file => depends_on('log_file'),
          }
      );
      
      service 'application' => (
          class        => 'MyApplication',
          dependencies => {
              logger => depends_on('logger'),
          }        
      );
      
  };
  
  $c->fetch('application')->run;

=head1 DESCRIPTION

=cut