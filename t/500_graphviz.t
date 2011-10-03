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
    ['/MyApp/config/config_file' => '/MyApp/name' ],
    ['/MyApp/config/dsn'         => '/MyApp/config/config_file'],
    ['/MyApp/config/dsn'         => '/MyApp/logger'],
    ['/MyApp/database'           => '/MyApp/config/dsn'],
    ['/MyApp/database'           => '/MyApp/logger'],
    ['/MyApp/pages/login'        => '/MyApp/database'],
    ['/MyApp/pages/login'        => '/MyApp/logger'],
    ['/MyApp/pages/login'        => '/MyApp/templates/login'],
    ['/MyApp/templates/login'    => '/MyApp/config/template_dir'],
], 'added all the edges';

done_testing;
