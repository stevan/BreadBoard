package Bread::Board::GraphViz::App;
use Moose;
# ABSTRACT: display a L<Bread::Board>'s dependency graph

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

__PACKAGE__->meta->make_immutable;

no Moose; 1;

__END__

=pod

=head1 SYNOPSIS

See L<visualize-breadboard.pl>.

=head1 AUTHOR (actual)

Jonathan Rockway - C<< <jrockway@cpan.org> >>

=head1 BUGS

All complex software has bugs lurking in it, and this module is no
exception. If you find a bug please either email me, or add the bug
to cpan-RT.

=begin Pod::Coverage

  run

=end Pod::Coverage

=cut
