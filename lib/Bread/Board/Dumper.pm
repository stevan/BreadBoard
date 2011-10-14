package Bread::Board::Dumper;
use Moose;

sub dump {
    my ($self, $thing, $indent) = @_;

    $indent = defined $indent ? $indent . '  ' : '';

    my $output = '';

    if ($thing->isa('Bread::Board::Dependency')) {
        $output .= join('', $indent, "depends_on: ", $thing->service_path || $thing->service->name, "\n");
    }
    elsif ($thing->does('Bread::Board::Service')) {
        $output .= join('', $indent, "service: ", $thing->name, "\n" );

        if ($thing->does('Bread::Board::Service::WithDependencies')) {
            while (my($key, $value) = each %{ $thing->dependencies }) {
                $output .= $self->dump($value, $indent);
            }
        }
    }
    elsif ($thing->isa('Bread::Board::Container')) {
        $output = join('', $indent, "container: ", $thing->name, "\n" );

        my ($key, $value);

        while (($key, $value) = each %{ $thing->sub_containers }) {
            $output .= $self->dump($value, $indent);
        }

        while (($key, $value) = each %{ $thing->services }) {
            $output .= $self->dump($value, $indent);
        }
    }

    return $output;
}

__PACKAGE__->meta->make_immutable;

no Moose; 1;

__END__

=pod

=head1 SYNOPSIS

  use Bread::Board::Dumper;

  print Bread::Board::Dumper->new->dump($container);

  # container: Application
  #   container: Controller
  #   container: View
  #     service: TT
  #       depends_on: include_path
  #   container: Model
  #     service: dsn
  #     service: schema
  #       depends_on: pass
  #       depends_on: ../dsn
  #       depends_on: user

=head1 DESCRIPTION

This is a useful utility for dumping a clean view of a Bread::Board
container.

=head1 AUTHOR (actual)

Daisuke Maki

=head1 BUGS

All complex software has bugs lurking in it, and this module is no
exception. If you find a bug please either email me, or add the bug
to cpan-RT.

=cut
