package Bread::Board::GraphViz::App;
use Moose;
use namespace::autoclean;

use Bread::Board::GraphViz;

with 'MooseX::Runnable';

sub run {
    my ($self, @code) = @_;
    my $board = eval( 'no strict; '. join ' ', @code );
    die if $@;

    if(!blessed $board || !$board->isa('Bread::Board::Container')){
        print {*STDERR} "That code did not evaluate to a Bread::Board::Container.\n";
        return 1;
    }

    my $g = Bread::Board::GraphViz->new;
    $g->add_container($board);
    print $g->graph->as_debug;

    return 0;
}

1;

__PACKAGE__->meta->make_immutable;

__END__

=head1 NAME

Bread::Board::GraphViz::App - display a L<Bread::Board>'s dependency graph

=head1 SYNOPSIS

See L<visualize-breadboard.pl>.

=head1 AUTHOR

Jonathan Rockway - C<< <jrockway@cpan.org> >>
