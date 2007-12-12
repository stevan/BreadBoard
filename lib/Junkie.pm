package Junkie;
use Moose;

1;

__END__

=pod

=head1 NAME

Junkie - A fix for what ails you

=head1 SYNOPSIS

# my class ...
package My::DBI;
use Moose;

has 'dsn'  => (is => 'rw', isa => 'Str');
has 'user' => (is => 'rw', isa => 'Str');
has 'pass' => (is => 'rw', isa => 'Str');

1;

# my IOC config
MyApp:
    DATABASE_USER: 'foo'
    ...
    Database:
        dsn:  'dbi:mysql:test'
        handle:
            class: My::DBI
            requires:
                - { dsn  => ./dsn }
                - { user => /DATABASE_USER }
            params:
                - pass

# pure perl
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
    }
};

=head1 DESCRIPTION

=cut