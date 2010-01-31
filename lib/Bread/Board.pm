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

use Moose::Exporter;
Moose::Exporter->setup_import_methods(
    as_is => [qw( as container depends_on service wire_names )],
);

our $AUTHORITY = 'cpan:STEVAN';
our $VERSION   = '0.10';

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
    Bread::Board::Dependency->new(service_path => $path);
}

__PACKAGE__->meta->make_immutable;

no Moose; 1;

__END__

=pod

=head1 NAME

Bread::Board - A solderless way to wire up you application components

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
          service 'dsn'      => "dbi:sqlite:dbname=my-app.db";
          service 'username' => "user234";
          service 'password' => "****";

          service 'dbh' => (
              block => sub {
                  my $s = shift;
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

  $c->fetch('application')->get->run;

=head1 DESCRIPTION

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

More docs to come, this is a very early release of this module.
Basically, if you don't grok the SYNOPSIS then check back later
when the docs are written (or feel free to read the tests, the
F<t/02*_sugar.t> tests are the most illustrative IMO).

=head1 EXPORTED FUNCTIONS

=over 4

=item I<container ($name, &body)>

=item I<as (&body)>

=item I<service ($name, $literal|%service_description)>

=item I<depends_on ($service_name)>

=item I<wire_names (@service_names)>

=back

=head1 METHODS

=over 4

=item B<set_root_container ($container)>

=item B<meta>

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

Copyright 2007-2009 by Infinity Interactive, Inc.

L<http://www.iinteractive.com>

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
