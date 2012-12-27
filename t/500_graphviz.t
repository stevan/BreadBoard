use strict;
use warnings;
use Test::More;
use Test::Fatal;

BEGIN {
    eval 'use Bread::Board::GraphViz; 1' or
        plan skip_all => 'you need the optional deps to do the graphviz stuff';
}

my $example_board = do('t/lib/graphable.bb');

my $g = Bread::Board::GraphViz->new;
is(exception {
    $g->add_container($example_board);
}, undef, 'adding works');

is_deeply [ sort map { $_->name } $g->services ], [
    sort qw/config_file dsn logger database login login template_dir name/,
], 'visited all the services';

sub cmp_edges {
    join(' => ', @$a) cmp join(' => ', @$b);
}

is_deeply [ sort cmp_edges map { [$_->{from}, $_->{to}] } $g->edges ], [
    ['/config/config_file' => '/name' ],
    ['/config/dsn'         => '/config/config_file'],
    ['/config/dsn'         => '/logger'],
    ['/database'           => '/config/dsn'],
    ['/database'           => '/logger'],
    ['/pages/login'        => '/database'],
    ['/pages/login'        => '/logger'],
    ['/pages/login'        => '/templates/login'],
    ['/templates/login'    => '/config/template_dir'],
], 'added all the edges';

done_testing;
