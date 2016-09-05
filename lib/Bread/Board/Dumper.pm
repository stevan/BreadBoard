package Bread::Board::Dumper;
# ABSTRACT: Pretty printer for visualizing the layout of your Bread::Board

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
            my $deps = $thing->dependencies;
            for my $key (sort keys %{$deps}) {
                $output .= $self->dump($deps->{$key}, $indent);
            }
        }
    }
    elsif ($thing->isa('Bread::Board::Container')) {
        $output = join('', $indent, "container: ", $thing->name, "\n" );

        $output .= $self->_dump_container($thing, $indent);
    }
    elsif ($thing->isa('Bread::Board::Container::Parameterized')) {
        my $params = join ', ', @{ $thing->allowed_parameter_names };
        $output = join('', $indent, "container: ", $thing->name, " [$params]\n" );
        $output .= $self->_dump_container($thing, $indent);
    }

    return $output;
}

sub _dump_container {
    my ($self, $c, $indent) = @_;

    my $output = '';

    my $subs = $c->sub_containers;
    for my $key (sort keys %{$subs}) {
        $output .= $self->dump($subs->{$key}, $indent);
    }

    my $services = $c->services;
    for my $key (sort keys %{$services}) {
        $output .= $self->dump($services->{$key}, $indent);
    }

    return $output;
}

__PACKAGE__->meta->make_immutable;

no Moose; 1;

__END__

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
