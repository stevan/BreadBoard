package Junkie;
use Moose;

1;

__END__

=pod

=head1 NAME

Junkie - A fix for what ails you

=head1 SYNOPSIS

container MyApp => is {
    
    service 'DATABASE_USER' => 'foo';
    
    container 'Database' => is {
        service 'dsn' => 'dbi:mysql:test';
        service 'handle' => {
            type     => 'ConstructorInjection',
            class    => 'My::DBI',
            params   => [qw[ password ]]
            requires => [
                { dsn  => $c->fetch('./dsn')          },
                { user => $c->fetch('/DATABASE_USER') },
            ],
        };
    };
    
    # run arbitrary code ...
    foreach my $i (0 .. 5) {
        service "Count$i" => $i;
    }
    
    if ($ENV{IS_PROD}) {
        # ...
    }
    else {
        # ....
    }
    
    service 'logger' => {
        type     => 'ConstructorInjection',
        lifecyle => 'Singleton'
        class    => 'My::Logger',
        requires => [
            { logfile  => $ENV{MY_APP_LOGFILE} },
        ],
    };    
};

=head1 DESCRIPTION

=cut