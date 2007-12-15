#!/usr/bin/perl

use strict;
use warnings;

use Test::More no_plan => 1;

BEGIN {
    use_ok('Junkie');

    use_ok('Junkie::Types');

    # roles
    use_ok('Junkie::Service');
    use_ok('Junkie::Service::WithClass');
    use_ok('Junkie::Service::WithDependencies');
    use_ok('Junkie::Service::WithParameters');

    # services
    use_ok('Junkie::ConstructorInjection');
    use_ok('Junkie::SetterInjection');
    use_ok('Junkie::BlockInjection');    
    use_ok('Junkie::Literal');
    
    use_ok('Junkie::Container');
    use_ok('Junkie::Dependency');
    
    use_ok('Junkie::Traversable');       
    
    use_ok('Junkie::LifeCycle::Singleton');       
}

{
    package FileLogger;
    use Moose;
    has 'log_file' => (is => 'ro', required => 1);
    
    package MyApplication;
    use Moose;
    has 'logger' => (is => 'ro', isa => 'FileLogger', required => 1);
}

=pod

my $container = IOC::Container->new();
  $container->register(IOC::Service::Literal->new('log_file' => "logfile.log"));
  $container->register(IOC::Service->new('logger' => sub { 
      my $c = shift; 
      return FileLogger->new($c->get('log_file'));
  }));
  $container->register(IOC::Service->new('application' => sub {
      my $c = shift; 
      my $app = Application->new();
      $app->logger($c->get('logger'));
      return $app;
  }));

  $container->get('application')->run();

=cut

sub loggers {
    service 'log_file' => "logfile.log";
    
    service 'logger' => (
        class        => 'FileLogger',
        lifecycle    => 'Singleton',
        dependencies => {
            log_file => depends_on('log_file'),
        }
    );    
}

my $c = container 'MyApp' => as {
    
    loggers(); # reuse baby !!!
    
    service 'application' => (
        class        => 'MyApplication',
        dependencies => {
            logger => depends_on('logger'),
        }        
    );
    
};

my $logger = $c->fetch('logger')->get;
isa_ok($logger, 'FileLogger');

is($logger->log_file, 'logfile.log', '... got the right logfile dep');

is($c->fetch('logger/log_file')->service, $c->fetch('log_file'), '... got the right value');
is($c->fetch('logger/log_file')->get, 'logfile.log', '... got the right value');

my $app = $c->fetch('application')->get;
isa_ok($app, 'MyApplication');

isa_ok($app->logger, 'FileLogger');
is($app->logger, $logger, '... got the right logger (singleton)');







