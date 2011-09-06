package Bread::Board::GraphViz::App;
use Moose;

use Bread::Board::GraphViz;

our $AUTHORITY = 'cpan:STEVAN';
our $VERSION   = '0.21';

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

=head1 NAME

Bread::Board::GraphViz::App - display a L<Bread::Board>'s dependency graph

=head1 SYNOPSIS

See L<visualize-breadboard.pl>.

=head1 BUGS

All complex software has bugs lurking in it, and this module is no
exception. If you find a bug please either email me, or add the bug
to cpan-RT.

=head1 AUTHOR

Jonathan Rockway - C<< <jrockway@cpan.org> >>

=head1 COPYRIGHT AND LICENSE

Copyright 2007-2011 by Infinity Interactive, Inc.

L<http://www.iinteractive.com>

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
