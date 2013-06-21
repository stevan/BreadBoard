package Bread::Board::Literal;
use Moose;
# ABSTRACT: Non-lazy services returning a literal scalar or reference

with 'Bread::Board::Service';

has 'value' => (
    is       => 'rw',
    isa      => 'Defined',
    required => 1,
);

sub get { (shift)->value }

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

=item B<get>

Returns the literal value stored in the service.

=item B<value>

This is the literal value stored and the one that will be returned by C<get>. 

=back

=head1 BUGS

All complex software has bugs lurking in it, and this module is no
exception. If you find a bug please either email me, or add the bug
to cpan-RT.

=cut
