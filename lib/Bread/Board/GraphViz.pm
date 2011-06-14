package Bread::Board::GraphViz;
use Moose;

use Data::Visitor::Callback;
use GraphViz;
use List::Util qw(reduce);
use MooseX::Types::Set::Object;
use Set::Object qw(set);

our $AUTHORITY = 'cpan:STEVAN';
our $VERSION   = '0.20';

# edges is built incrementally, as a user may provide many "root" containers
has 'edges' => (
    init_arg => 'edges', # feel free to supply your own
    isa      => 'ArrayRef[HashRef]',
    traits   => ['Array'],
    default  => sub { [] },
    handles  => {
        edges     => 'elements',
        push_edge => 'push',
    },
);

has 'services' => (
    isa     => 'Set::Object',
    default => sub { set },
    handles => {
        push_service => 'insert',
        services     => 'members',
    },
);

has 'visitor' => (
    isa        => 'Data::Visitor::Callback',
    lazy_build => 1,
    handles    => {
        add_container => 'visit',
    },
);

sub service_name {
    my $service = shift;
    return '' unless $service;
    return join '/', service_name($service->parent), $service->name;
}

sub name_prefix {
    my ($self) = @_;
    return reduce {
        my $i = 0;
        for(;substr($a, $i, 1) eq substr($b, $i, 1); $i++){}
        substr $a, 0, $i;
    } map { service_name($_) } $self->services;
}

sub _build_visitor {
    my ($self) = @_;

    my $v = Data::Visitor::Callback->new(
        'Bread::Board::Container' => sub {
            for my $c ($_->get_sub_container_list){
                $_[0]->visit($_->get_sub_container($c));
            }
            for my $s ($_->get_service_list) {
                $_[0]->visit($_->get_service($s));
            }
            return $_;
        },
        'object' => sub {
            if($_->does('Bread::Board::Service')){
                $self->push_service($_);
            }

            if($_->does('Bread::Board::Service::WithDependencies')){
                for my $dep (map { $_->[1] } $_->get_all_dependencies){
                    $self->push_edge({
                        from => service_name($_),
                        to   => service_name($dep->service),
                        via  => $dep->service_name,
                    });
                }
            }
            return $_;
        },
    );
    return $v;
}

sub graph {
    my ($self, $viz, %params) = @_;
    $viz ||= GraphViz->new;

    my $prefix = $self->name_prefix;
    my $fix = sub {
        substr $_[0], length($prefix);
    };

    for my $service ($self->services) {
        $viz->add_node(
            $fix->(service_name($service)),
            fontsize => 12,
            shape    => $service->does('Bread::Board::LifeCycle::Singleton') ?
                         'ellipse' : 'box',
        );
    }

    for my $edge ($self->edges) {
        $viz->add_edge(
            $fix->($edge->{from}) => $fix->($edge->{to}),
            fontsize => 9,
            label    => $edge->{via},
        );
    }

    return $viz;
}

__PACKAGE__->meta->make_immutable;

no Moose; 1;

__END__

=pod

=head1 NAME

Bread::Board::GraphViz - visualize L<Bread::Board> dependency graphs

=head1 SYNOPSIS

   my $g = Bread::Board::GraphViz->new;
   $g->add_container( $bread_board_container );
   print $g->graph->as_png;

=head1 SEE ALSO

L<Bread::Board::GraphViz::App>

L<GraphViz>

L<GraphViz::HasA>

=head1 AUTHOR

Jonathan Rockway - C<< <jrockway@cpan.org> >>

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
