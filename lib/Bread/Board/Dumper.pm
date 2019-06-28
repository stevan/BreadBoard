package Bread::Board::Dumper;
our $AUTHORITY = 'cpan:STEVAN';
# ABSTRACT: Pretty printer for visualizing the layout of your Bread::Board
$Bread::Board::Dumper::VERSION = '0.37';
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

=pod

=encoding UTF-8

=head1 NAME

Bread::Board::Dumper - Pretty printer for visualizing the layout of your Bread::Board

=head1 VERSION

version 0.37

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

=head1 AUTHOR

Stevan Little <stevan@iinteractive.com>

=head1 BUGS

Please report any bugs or feature requests on the bugtracker website
https://github.com/stevan/BreadBoard/issues

When submitting a bug or request, please include a test-file or a
patch to an existing test-file that illustrates the bug or desired
feature.

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2019, 2017, 2016, 2015, 2014, 2013, 2011, 2009 by Infinity Interactive.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
