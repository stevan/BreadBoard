#!/usr/bin/perl

use strict;
use warnings;

use Test::More;
use Test::Exception;

BEGIN {
    use_ok('Bread::Board');
}

{
    package My::Database::Handle;
    use Moose;

    has ['dsn', 'username', 'password'] => ( is => 'ro', isa => 'Str', required => 1 );
}

my $utils = container 'Utils' => as {
    container 'Database' => [ 'DBConnInfo' ] => as {
        service 'handle' => (
            class        => 'My::Database::Handle',
            dependencies => {
                dsn      => depends_on('DBConnInfo/dsn'),
                username => depends_on('DBConnInfo/username'),
                password => depends_on('DBConnInfo/password'),
            }
        );
    };
};
isa_ok($utils, 'Bread::Board::Container');

my $db_conn_info = container 'DatabaseConnection' => as {
    service 'dsn'      => 'dbi:mysql:foo';
    service 'username' => 'bar';
    service 'password' => '***';
};
isa_ok($db_conn_info, 'Bread::Board::Container');

my $db = $utils->fetch('Utils/Database');
isa_ok($db, 'Bread::Board::Container::Parameterized');

dies_ok {
    $utils->fetch('Utils/Database')->fetch('handle');
} '... cannot fetch on a parameterized container';

dies_ok {
    $utils->fetch('Utils/Database/handle');
} '... cannot fetch within a parameterized container';

my $dbh = $db->create( DBConnInfo => $db_conn_info )->resolve( service => 'handle' );
isa_ok($dbh, 'My::Database::Handle');

done_testing;


