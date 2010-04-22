#!/usr/bin/perl

use strict;
use warnings;

use Test::More;
use Test::Exception;
use Test::Moose;

BEGIN {
    eval "use Log::Dispatch; use Log::Dispatch::File; use Log::Dispatch::Screen;";
    plan skip_all => "This test requires Log::Dispatch to be installed" if $@;
    use_ok('Bread::Board');
}

my $c = container 'Logging' => as {
    service 'Logger' => (
        block => sub {
            my $s       = shift;
            my $c       = $s->parent;
            my $outputs = $c->get_sub_container('Outputs');
            my $log     = Log::Dispatch->new;
            foreach my $name ( $outputs->get_service_list ) {
                $log->add(
                    $outputs->get_service( $name )->get
                );
            }
            $log;
        }
    );

    container 'Outputs' => as {
        service 'File' => (
            block => sub {
                Log::Dispatch::File->new(
                    name      => 'file',
                    min_level => 'debug',
                    filename  => 'logfile'
                )
            }
        );
        service 'Screen' => (
            block => sub {
                Log::Dispatch::Screen->new(
                    name      => 'screen',
                    min_level => 'warning',
                )
            }
        );
    };
};

my $logger = $c->fetch('Logging/Logger')->get;
isa_ok($logger, 'Log::Dispatch');

my $screen = $logger->output('screen');
isa_ok($screen, 'Log::Dispatch::Screen');

my $file = $logger->output('file');
isa_ok($file, 'Log::Dispatch::File');

unlink 'logfile';

done_testing;
