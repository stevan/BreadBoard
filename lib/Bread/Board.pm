package Bread::Board;
use strict;
use warnings;
use Carp qw(confess);
use Scalar::Util qw(blessed);

use Bread::Board::Types;
use Bread::Board::ConstructorInjection;
use Bread::Board::SetterInjection;
use Bread::Board::BlockInjection;
use Bread::Board::Literal;
use Bread::Board::Container;
use Bread::Board::Container::Parameterized;
use Bread::Board::Dependency;
use Bread::Board::LifeCycle::Singleton;
use Bread::Board::Service::Inferred;
use Bread::Board::Service::Alias;

use Moose::Exporter;
Moose::Exporter->setup_import_methods(
    as_is => [qw[
        as
        container
        depends_on
        service
        alias
        wire_names
        include
        typemap
        infer
    ]],
);

our $AUTHORITY = 'cpan:STEVAN';
our $VERSION   = '0.20';

sub as (&) { $_[0] }

our $CC;

sub set_root_container {
    (defined $CC && confess "Cannot set the root container, CC is already defined $CC");
    $CC = shift;
}

sub container ($;$$) {
    my $name        = shift;
    my $name_is_obj = blessed $name && $name->isa('Bread::Board::Container') ? 1 : 0;

    my $c;
    if ( scalar @_ == 0 ) {
        return $name if $name_is_obj;
        return Bread::Board::Container->new(
            name => $name
        );
    }
    elsif ( scalar @_ == 1 ) {
        $c = $name_is_obj
            ? $name
            : Bread::Board::Container->new( name => $name );
    }
    else {
        confess 'container($object, ...) is not supported for parameterized containers'
            if $name_is_obj;
        my $param_names = shift;
        $c = Bread::Board::Container::Parameterized->new(
            name                    => $name,
            allowed_parameter_names => $param_names,
        )
    }
    my $body = shift;
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

sub include ($) {
    my $file = shift;
    if (my $ret = do $file) {
        return $ret;
    }
    else {
        confess "Couldn't compile $file: $@" if $@;
        confess "Couldn't open $file for reading: $!" if $!;
        confess "Unknown error when compiling $file";
    }
}

sub service ($@) {
    my $name = shift;
    my $s;
    if (scalar @_ == 1) {
        $s = Bread::Board::Literal->new(name => $name, value => $_[0]);
    }
    elsif (scalar(@_) % 2 == 0) {
        my %params = @_;
        if ($params{service_class}) {
            ($params{service_class}->does('Bread::Board::Service'))
                || confess "The service class must do the Bread::Board::Service role";
            $s = $params{service_class}->new(name => $name, %params);
        }
        else {
            my $type   = $params{service_type} || (exists $params{block} ? 'Block' : 'Constructor');
            $s = "Bread::Board::${type}Injection"->new(name => $name, %params);
        }
    }
    else {
        confess "I don't understand @_";
    }
    return $s unless defined $CC;
    $CC->add_service($s);
}

sub alias ($$@) {
    my $name = shift;
    my $path = shift;
    my %params = @_;

    my $s = Bread::Board::Service::Alias->new(
        name              => $name,
        aliased_from_path => $path,
        %params,
    );
    return $s unless defined $CC;
    $CC->add_service($s);
}

sub typemap ($@) {
    my $type = shift;

    (scalar @_ == 1)
        || confess "Too many (or too few) arguments to typemap";

    my $service;
    if (blessed $_[0]) {
        if ($_[0]->does('Bread::Board::Service')) {
            $service = $_[0];
        }
        elsif ($_[0]->isa('Bread::Board::Service::Inferred')) {
            $service = $_[0]->infer_service( $type );
        }
        else {
            confess "No idea what to do with a " . $_[0];
        }
    }
    else {
        $service = $CC->fetch( $_[0] );
    }

    $CC->add_type_mapping_for( $type, $service );
}

sub infer {
    if (@_ == 1) {
        return Bread::Board::Service::Inferred->new(
            current_container => $CC,
            service           => $_[0],
            infer_params      => 1,
        );
    }
    else {
        my %params = @_;
        return Bread::Board::Service::Inferred->new(
            current_container => $CC,
            service_args      => \%params,
            infer_params      => 1,
        );
    }
}

sub wire_names { +{ map { $_ => depends_on($_) } @_ }; }

sub depends_on ($) {
    my $path = shift;
    Bread::Board::Dependency->new(service_path => $path);
}

1;

__END__

=pod

=head1 NAME

Bread::Board - A solderless way to wire up your application components

=head1 SYNOPSIS

  use Bread::Board;

  my $c = container 'MyApp' => as {

      service 'log_file_name' => "logfile.log";

      service 'logger' => (
          class        => 'FileLogger',
          lifecycle    => 'Singleton',
          dependencies => [
              depends_on('log_file_name'),
          ]
      );

      container 'Database' => as {
          service 'dsn'      => "dbi:SQLite:dbname=my-app.db";
          service 'username' => "user234";
          service 'password' => "****";

          service 'dbh' => (
              block => sub {
                  my $s = shift;
                  require DBI;
                  DBI->connect(
                      $s->param('dsn'),
                      $s->param('username'),
                      $s->param('password'),
                  ) || die "Could not connect";
              },
              dependencies => wire_names(qw[dsn username password])
          );
      };

      service 'application' => (
          class        => 'MyApplication',
          dependencies => {
              logger => depends_on('logger'),
              dbh    => depends_on('Database/dbh'),
          }
      );

  };

  no Bread::Board; # removes keywords

  # get an instance of MyApplication
  # from the container
  my $app = $c->resolve( service => 'application' );

  # now user your MyApplication
  # as you normally would ...
  $app->run;

=head1 DESCRIPTION

Bread::Board is an inversion of control framework with a focus on
dependency injection and lifecycle management. It's goal is to
help you write more decoupled objects and components by removing
the need for you to manually wire those objects/components together.

Want to know more? See the L<Bread::Board::Manual>.

  +-----------------------------------------+
  |          A B C D E   F G H I J          |
  |-----------------------------------------|
  | o o |  1 o-o-o-o-o v o-o-o-o-o 1  | o o |
  | o o |  2 o-o-o-o-o   o-o-o-o-o 2  | o o |
  | o o |  3 o-o-o-o-o   o-o-o-o-o 3  | o o |
  | o o |  4 o-o-o-o-o   o-o-o-o-o 4  | o o |
  | o o |  5 o-o-o-o-o   o-o-o-o-o 5  | o o |
  |     |  6 o-o-o-o-o   o-o-o-o-o 6  |     |
  | o o |  7 o-o-o-o-o   o-o-o-o-o 7  | o o |
  | o o |  8 o-o-o-o-o   o-o-o-o-o 8  | o o |
  | o o |  9 o-o-o-o-o   o-o-o-o-o 9  | o o |
  | o o | 10 o-o-o-o-o   o-o-o-o-o 10 | o o |
  | o o | 11 o-o-o-o-o   o-o-o-o-o 11 | o o |
  |     | 12 o-o-o-o-o   o-o-o-o-o 12 |     |
  | o o | 13 o-o-o-o-o   o-o-o-o-o 13 | o o |
  | o o | 14 o-o-o-o-o   o-o-o-o-o 14 | o o |
  | o o | 15 o-o-o-o-o   o-o-o-o-o 15 | o o |
  | o o | 16 o-o-o-o-o   o-o-o-o-o 16 | o o |
  | o o | 17 o-o-o-o-o   o-o-o-o-o 17 | o o |
  |     | 18 o-o-o-o-o   o-o-o-o-o 18 |     |
  | o o | 19 o-o-o-o-o   o-o-o-o-o 19 | o o |
  | o o | 20 o-o-o-o-o   o-o-o-o-o 20 | o o |
  | o o | 21 o-o-o-o-o   o-o-o-o-o 21 | o o |
  | o o | 22 o-o-o-o-o   o-o-o-o-o 22 | o o |
  | o o | 22 o-o-o-o-o   o-o-o-o-o 22 | o o |
  |     | 23 o-o-o-o-o   o-o-o-o-o 23 |     |
  | o o | 24 o-o-o-o-o   o-o-o-o-o 24 | o o |
  | o o | 25 o-o-o-o-o   o-o-o-o-o 25 | o o |
  | o o | 26 o-o-o-o-o   o-o-o-o-o 26 | o o |
  | o o | 27 o-o-o-o-o   o-o-o-o-o 27 | o o |
  | o o | 28 o-o-o-o-o ^ o-o-o-o-o 28 | o o |
  +-----------------------------------------+

=head1 EXPORTED FUNCTIONS

=over 4

=item I<container ($name, &body)>

=item I<container ($container_instance, &body)>

=item I<container ($name, [ @parameters ], &body)>

=item I<as (&body)>

=item I<service ($name, $literal | %service_description)>

=item I<depends_on ($service_path)>

=item I<wire_names (@service_names)>

=item I<typemap ($type, $service | $service_path)>

=item I<infer (?%hints)>

=item I<include ($file)>

=back

=head1 ACKNOWLEDGEMENTS

Thanks to Daisuke Maki for his contributions and for really
pushing the development of this module along.

Chuck "sprongie" Adams, for testing/using early (pre-release)
versions of this module, and some good suggestions for naming
it.

Matt "mst" Trout, for finally coming up with the best name
for this module.

=head1 SEE ALSO

=over 4

=item L<IOC>

Bread::Board is basically my re-write of IOC.

=item L<http://en.wikipedia.org/wiki/Breadboard>

=back

=head1 BUGS

All complex software has bugs lurking in it, and this module is no
exception. If you find a bug please either email me, or add the bug
to cpan-RT.

=head1 AUTHOR

Stevan Little E<lt>stevan@iinteractive.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright 2007-2011 by Infinity Interactive, Inc.

L<http://www.iinteractive.com>

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
