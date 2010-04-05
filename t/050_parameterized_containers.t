#!/usr/bin/perl

use strict;
use warnings;

use Test::More;
use Test::Exception;

BEGIN {
    use_ok('Bread::Board');
}

{
    package My::Simple::Logger;
    use Moose;

    package My::Database::Logger;
    use Moose;

    has ['dsn', 'username', 'password'] => ( is => 'ro', isa => 'Str', required => 1 );

    package My::Application;
    use Moose;

    has 'log_handle' => ( is => 'ro', isa => 'Object', required => 1 );
}

my $simple_logger = container 'SimpleLogger' => as {
    service 'handle' => (
        class => 'My::Simple::Logger'
    );
};
isa_ok($simple_logger, 'Bread::Board::Container');

my $db_conn_info = container 'DatabaseConnection' => as {
    service 'dsn'      => 'dbi:mysql:foo';
    service 'username' => 'bar';
    service 'password' => '***';
};
isa_ok($db_conn_info, 'Bread::Board::Container');

my $db_logger = container 'DatabaseLogger' => [ 'DBConnInfo' ] => as {
    service 'handle' => (
        class        => 'My::Database::Logger',
        dependencies => {
            dsn      => depends_on('DBConnInfo/dsn'),
            username => depends_on('DBConnInfo/username'),
            password => depends_on('DBConnInfo/password'),
        }
    );
};
isa_ok($db_logger, 'Bread::Board::Container::Parameterized');

dies_ok {
    $db_logger->fetch('handle')
} '... cannot call fetch on a parameterized container';

my $app = container 'Application' => [ 'Logger' ] => as {
    service 'app' => (
        class        => 'My::Application',
        dependencies => {
            log_handle => depends_on('Logger/handle')
        }
    );
};
isa_ok($app, 'Bread::Board::Container::Parameterized');

dies_ok {
    $app->fetch('handle')
} '... cannot call fetch on a parameterized container';

my $simple_app = $app->create( Logger => $simple_logger );
isa_ok($simple_app, 'Bread::Board::Container');

isa_ok($simple_app->fetch('app')->get->log_handle, 'My::Simple::Logger');

my $db_app = $app->create( Logger => $db_logger->create( DBConnInfo => $db_conn_info ) );
isa_ok($db_app, 'Bread::Board::Container');

isa_ok($db_app->fetch('app')->get->log_handle, 'My::Database::Logger');

done_testing;


