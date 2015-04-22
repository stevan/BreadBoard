use 5.006;
use strict;
use warnings;

# this test was generated with Dist::Zilla::Plugin::Test::Compile 2.051

use Test::More;

plan tests => 23 + ($ENV{AUTHOR_TESTING} ? 1 : 0);

my @module_files = (
    'Bread/Board.pm',
    'Bread/Board/BlockInjection.pm',
    'Bread/Board/ConstructorInjection.pm',
    'Bread/Board/Container.pm',
    'Bread/Board/Container/FromParameterized.pm',
    'Bread/Board/Container/Parameterized.pm',
    'Bread/Board/Dependency.pm',
    'Bread/Board/Dumper.pm',
    'Bread/Board/LifeCycle.pm',
    'Bread/Board/LifeCycle/Singleton.pm',
    'Bread/Board/LifeCycle/Singleton/WithParameters.pm',
    'Bread/Board/Literal.pm',
    'Bread/Board/Service.pm',
    'Bread/Board/Service/Alias.pm',
    'Bread/Board/Service/Deferred.pm',
    'Bread/Board/Service/Deferred/Thunk.pm',
    'Bread/Board/Service/Inferred.pm',
    'Bread/Board/Service/WithClass.pm',
    'Bread/Board/Service/WithDependencies.pm',
    'Bread/Board/Service/WithParameters.pm',
    'Bread/Board/SetterInjection.pm',
    'Bread/Board/Traversable.pm',
    'Bread/Board/Types.pm'
);



# no fake home requested

my $inc_switch = -d 'blib' ? '-Mblib' : '-Ilib';

use File::Spec;
use IPC::Open3;
use IO::Handle;

open my $stdin, '<', File::Spec->devnull or die "can't open devnull: $!";

my @warnings;
for my $lib (@module_files)
{
    # see L<perlfaq8/How can I capture STDERR from an external command?>
    my $stderr = IO::Handle->new;

    my $pid = open3($stdin, '>&STDERR', $stderr, $^X, $inc_switch, '-e', "require q[$lib]");
    binmode $stderr, ':crlf' if $^O eq 'MSWin32';
    my @_warnings = <$stderr>;
    waitpid($pid, 0);
    is($?, 0, "$lib loaded ok");

    if (@_warnings)
    {
        warn @_warnings;
        push @warnings, @_warnings;
    }
}



is(scalar(@warnings), 0, 'no warnings found')
    or diag 'got warnings: ', ( Test::More->can('explain') ? Test::More::explain(\@warnings) : join("\n", '', @warnings) ) if $ENV{AUTHOR_TESTING};


