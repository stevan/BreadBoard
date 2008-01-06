package Bread::Board;
use Moose;

use Bread::Board::Types;

use Bread::Board::ConstructorInjection;
use Bread::Board::SetterInjection;
use Bread::Board::BlockInjection;
use Bread::Board::Literal;

use Bread::Board::Container;
use Bread::Board::Dependency;

use Bread::Board::LifeCycle::Singleton;

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

my @exports = qw[
    container
    service
    as
    depends_on
    wire_names
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
    my $c = Bread::Board::Container->new(name => $name);
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
        $s = Bread::Board::Literal->new(name => $name, value => $_[0]);
    }
    elsif (scalar(@_) % 2 == 0) {
        my %params = @_;
        my $type   = $params{type} || (exists $params{block} ? 'Block' : 'Constructor');
        $s =  "Bread::Board::${type}Injection"->new(name => $name, %params);
    }
    else {
        confess "I don't understand @_";
    }
    $CC->add_service($s);
}

sub wire_names { +{ map { $_ => depends_on($_) } @_ }; }

sub depends_on ($) {
    my $path = shift;
    Bread::Board::Dependency->new(service_path => ('../../' . $path));
}

1;

__END__

=pod

=head1 NAME

Bread::Board - A fix for what ails you

=head1 SYNOPSIS

  use Bread::Board;

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