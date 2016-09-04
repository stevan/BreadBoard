package Bread::Board::Literal;
# ABSTRACT: service providing a literal value

use Moose;

with 'Bread::Board::Service';

has 'value' => (
    is       => 'rw',
    required => 1,
);

sub get { (shift)->value }

sub clone_and_inherit_params {
    confess 'Trying to inherit from a literal service';
}

__PACKAGE__->meta->make_immutable;

no Moose; 1;

__END__

=pod

=head1 SYNOPSIS

  my $c = container PrettyBoring => as {

      # These are Bread::Board::Literal services
      service connect_string => 'dbi:mysql:boring_db';
      service service_url => 'http://api.example.com/v0/boring';

      # And some other services depending on them...

      service dbconn => (
          class => 'DBI',
          block => sub {
              my $s = shift;
              DBI->new($s->param('connect_string');
          },
          dependencies => wire_names(qw( connect_string )),
      );

      service service_request => (
          class => 'HTTP::Request',
          block => sub {
              my $s = shift;
              HTTP::Request->new(POST => $s->param('service_url'));
          },
          dependencies => wire_names(qw( service_url ));
      };
  };

  # OR to use directly:
  my $literal = Bread::Board::Literal->new(
      name  => 'the_answer_to_life_the_universe_and_everything',
      value => 42,
  );
  $c->add_service($literal);

=head1 DESCRIPTION

A literal service is one that stores a literal scalar or reference for use in
your Bread::Board.

Beware of using references in your literals as they may cause your Bread::Board
to leak memory. If this is a concern, you may want to weaken your references.

See L<Scalar::Util/weaken>.

=head1 METHODS

=over 4

=attr C<value>

Required attribute with read/write accessor. This is the value that
L</get> will return.

=method C<get>

Returns the L</value>, unaltered.

=method C<clone_and_inherit_params>

Dies: a literal service is (essentially) a constant, it does not make
sense to inherit from it.
