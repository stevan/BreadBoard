package Bread::Board;
use Moose;

use Bread::Board::Types;
use Bread::Board::ConstructorInjection;
use Bread::Board::SetterInjection;
use Bread::Board::BlockInjection;
use Bread::Board::Literal;
use Bread::Board::Container;
use Bread::Board::Dependency;
use Bread::Board::LifeCycle::Singleton;

use Moose::Exporter;
Moose::Exporter->setup_import_methods(
    as_is => [qw( as container depends_on service wire_names include )],
);

our $AUTHORITY = 'cpan:STEVAN';
our $VERSION   = '0.11';

sub as (&) { $_[0] }

our $CC;

sub set_root_container {
    (defined $CC && confess "Cannot set the root container, CC is already defined $CC");
    $CC = shift;
}

sub container ($;$) {
    my ($name, $body) = @_;
    my $c = Bread::Board::Container->new(name => $name);
    if (defined $CC) {
        $CC->add_sub_container($c);
    }
    if (defined $body) {
        local $_  = $c;
        local $CC = $c;
        $body->($c);
    }
    return $c;
}

sub include ($) { do shift }

sub service ($@) {
    my $name = shift;
    my $s;
    if (scalar @_ == 1) {
        $s = Bread::Board::Literal->new(name => $name, value => $_[0]);
    }
    elsif (scalar(@_) % 2 == 0) {
        my %params = @_;
        my $type   = $params{type} || (exists $params{block} ? 'Block' : 'Constructor');
        $s =  "Bread::Board::${type}Injection"->new(name => $name, %params);
    }
    else {
        confess "I don't understand @_";
    }
    $CC->add_service($s);
}

sub wire_names { +{ map { $_ => depends_on($_) } @_ }; }

sub depends_on ($) {
    my $path = shift;
    Bread::Board::Dependency->new(service_path => $path);
}

__PACKAGE__->meta->make_immutable;

no Moose; 1;

__END__

=pod

=head1 NAME

Bread::Board - A solderless way to wire up you application components

=head1 SYNOPSIS

  use Bread::Board;

  my $c = container 'MyApp' => as {

      service 'log_file_name' => "logfile.log";

      service 'logger' => (
          class        => 'FileLogger',
          lifecycle    => 'Singleton',
          dependencies => [
              depends_on('log_file_name'),
          ]
      );

      container 'Database' => as {
          service 'dsn'      => "dbi:sqlite:dbname=my-app.db";
          service 'username' => "user234";
          service 'password' => "****";

          service 'dbh' => (
              block => sub {
                  my $s = shift;
                  DBI->connect(
                      $s->param('dsn'),
                      $s->param('username'),
                      $s->param('password'),
                  ) || die "Could not connect";
              },
              dependencies => wire_names(qw[dsn username password])
          );
      };

      service 'application' => (
          class        => 'MyApplication',
          dependencies => {
              logger => depends_on('logger'),
              dbh    => depends_on('Database/dbh'),
          }
      );

  };

  no Bread::Board; # removes keywords

  $c->fetch('application')->get->run;

=head1 DESCRIPTION

  +-----------------------------------------+
  |          A B C D E   F G H I J          |
  |-----------------------------------------|
  | o o |  1 o-o-o-o-o v o-o-o-o-o 1  | o o |
  | o o |  2 o-o-o-o-o   o-o-o-o-o 2  | o o |
  | o o |  3 o-o-o-o-o   o-o-o-o-o 3  | o o |
  | o o |  4 o-o-o-o-o   o-o-o-o-o 4  | o o |
  | o o |  5 o-o-o-o-o   o-o-o-o-o 5  | o o |
  |     |  6 o-o-o-o-o   o-o-o-o-o 6  |     |
  | o o |  7 o-o-o-o-o   o-o-o-o-o 7  | o o |
  | o o |  8 o-o-o-o-o   o-o-o-o-o 8  | o o |
  | o o |  9 o-o-o-o-o   o-o-o-o-o 9  | o o |
  | o o | 10 o-o-o-o-o   o-o-o-o-o 10 | o o |
  | o o | 11 o-o-o-o-o   o-o-o-o-o 11 | o o |
  |     | 12 o-o-o-o-o   o-o-o-o-o 12 |     |
  | o o | 13 o-o-o-o-o   o-o-o-o-o 13 | o o |
  | o o | 14 o-o-o-o-o   o-o-o-o-o 14 | o o |
  | o o | 15 o-o-o-o-o   o-o-o-o-o 15 | o o |
  | o o | 16 o-o-o-o-o   o-o-o-o-o 16 | o o |
  | o o | 17 o-o-o-o-o   o-o-o-o-o 17 | o o |
  |     | 18 o-o-o-o-o   o-o-o-o-o 18 |     |
  | o o | 19 o-o-o-o-o   o-o-o-o-o 19 | o o |
  | o o | 20 o-o-o-o-o   o-o-o-o-o 20 | o o |
  | o o | 21 o-o-o-o-o   o-o-o-o-o 21 | o o |
  | o o | 22 o-o-o-o-o   o-o-o-o-o 22 | o o |
  | o o | 22 o-o-o-o-o   o-o-o-o-o 22 | o o |
  |     | 23 o-o-o-o-o   o-o-o-o-o 23 |     |
  | o o | 24 o-o-o-o-o   o-o-o-o-o 24 | o o |
  | o o | 25 o-o-o-o-o   o-o-o-o-o 25 | o o |
  | o o | 26 o-o-o-o-o   o-o-o-o-o 26 | o o |
  | o o | 27 o-o-o-o-o   o-o-o-o-o 27 | o o |
  | o o | 28 o-o-o-o-o ^ o-o-o-o-o 28 | o o |
  +-----------------------------------------+

=head1 CONCEPTS

=head1 What is Inversion of Control?

Inversion of Control (or IoC) is the very simple idea of releasing control of some part of your application over to some other part of your application, be it your code or an outside framework.

IoC is a common paradigm in GUI frameworks, whereby you give up control of your application flow to the framework and install your code at callbacks hooks within the framework. For example, take a very simple command line interface; the application asks a question, the user responds, the application processes the answer and asks another question, and so on until it is done. Now consider the GUI approach for the same application; the application displays a screen and goes into an event loop, users actions are processed with event handlers and callback functions. The GUI framework has inverted the control of the application flow and releived your code from having to deal with it.

IoC is also sometimes referred to as 'Dependency Injection' or the 'Dependency Injection Principle', and many people confused the two. However IoC and dependency injection are not the same, in fact the concepts behind dependency injection are actually just an I<example of> IoC principles in action, in particular about your applications dependency relationships. IoC is also sometimes referred to as the Hollywood Principle because of the I<don't call us we'll call you> approach of things like callback functions and event handlers.

Howard Lewis Ship, the creator of the HiveMind IoC Framework, once referred to dependency injection as being the inverse of garbage collection. With garbage collection you hand over the details of the destruction of you objects to the garbage collector. With dependency injection you are handing over control of object creation, which also includes the satisfaction of your dependency relationships.

The following sections will explain the basis concepts around the Bread::Board and how it relates to the concept of IoC.

=head2 Containers

The central part of just about any IoC framework is the container. A container's responsibilities are roughly to dispense services and to handle the resolution of said services's dependency relationships.

First we can start with a simple container for our services to live in. We give the container a name so that we can address it later on, think of this like a package namespace.

  my $c = Bread::Board::Container->new( name => 'Application' );

Next we need to add a service to that container (we will explain services a little later on).

  $c->add_service(
      Bread::Board::BlockInjection->new(
          name  => 'logger',
          block => sub { Logger->new() }
      )
  );

Now if we want an instance of our 'logger' service, we simply ask the container for it.

  my $logger_service = $c->fetch('logger');

And we then can ask the service to give us an instance of our Logger object.

  my $logger = $logger_service->get;

Its just that simple.

=head2 Dependency Management

Dependency management is also quite simple, and is easily shown with an example. But first lets create another component for our container, a database connection.

  $c->add_service(
      Bread::Board::BlockInjection->new(
          name  => 'db_conn',
          block => sub { DBI->connect('dbi:mysql:test', '', '') }
      )
  );

Now lets add an authenticator to our container. The authenticator requires both a database connection and a logger instance in it's constructor. We specify dependency relationships between services by providing a HASH of Bread::Board::Dependency objects which themselves have a path to the services they depend upon. In this case since all these services are in the same container, the service path is simply the name.

  $c->add_service(
      Bread::Board::BlockInjection->new(
          name  => 'authenticator',
          block => sub {
                my $service = shift;
                Authenticator->new(
                    db_conn => $service->param('db_conn'),
                    logger  => $service->param('logger')
                );
          },
          dependencies => {
              db_conn => Bread::Board::Dependency->new(service_path => 'db_conn'),
              logger  => Bread::Board::Dependency->new(service_path => 'logger'),
          }
      )
  );

As you can see, the first argument to our service subroutine is actually our service instance. Through this we can access the resolved dependencies and use them in our Authenticator object's constructor.

The above example is deceptively simple, but really powerful. What you don't see on the surface is that Bread::Board is completely managing initialization order for you. No longer to do you need to worry if your database is connected or your logger initialized and in what order you need to do that initialization, Bread::Board handles that all for you, including circular dependencies. This may not seem terribly interesting in such a small example, but the larger an application grows, the more sensitive it becomes to these kinds of initialization order issues.

=head2 Lifecycle Management

The default lifecycle for Bread::Board::Service components is a 'prototype' lifecycle, which means each time we ask for say, the logger, we will get a new instance back. There is also another option for lifecycle management that we call 'Singleton'. Here is an example of how we would use the 'Singleton' lifecycle to ensure that you always get back the same logger instance.

  $c->add_service(
      Bread::Board::BlockInjection->new(
          lifecycle => 'Singleton',
          name      => 'logger',
          block     => sub { Logger->new() }
      )
  );

Now each time we request a new logger component from our container we will get the exact same instance. Being able to change between the different lifecycles by simply changing one service parameter can come in very handy as you application grows. Extending this idea, it is possible to see how you could create your own custom service objects to manage your specific lifecycle needs, such as a pool of database connections.

=head2 Services

Up until now, we have shown the default way of creating a service by using the Bread::Board::BlockInjection and an anonymous subroutine. But this is not the only way to go about this. Those who have encountered IoC in the Java world may be familiar with the idea that there are 3 'types' of IoC/Dependency Injection; Constructor Injection, Setter Injection, and Interface Injection. In Bread::Board we support both Constructor and Setter injection, it is the authors opinion though that Interface injection was not only too complex, but highly java specific and the concept did not adapt itself well to perl.

=over 4

=item Block Injection

While not in the 'official' 3 types (mostly because its not possible in Java), but found in a few Ruby IoC frameworks, BlockInjection is by far the most versitile type. It simply requires a subroutine and a name and you do all the rest of it yourself.

  $c->add_service(
      Bread::Board::BlockInjection->new(
          name  => 'logger',
          class => 'ComplexLogger',
          block => sub {
              my $s = shift;
              my $l = ComplexLogger->new( file => $s->param('log_file') );
              $l->init_with_timezone( $s->param('timezone') );
              $l->log_timestamp;
              $l;
          },
          dependencies => {
              log_file => Bread::Board::Dependency->new( service_path => 'log_file' ),
              timezone => Bread::Board::Dependency->new( service_path => 'timezone' ),
          }
      )
  );

BlockInjection comes in really handy when your object requires more then just constructor parameters and needs some more complex initialization code. As long as your subroutine block returns an object, everything else is fair game. Also note the optional 'class' parameter, which when supplied will perform a basic type check on the result of the subroutine block.

=item Constructor Injection

Bread::Board also supports Constructor Injection. With constructor injection, the service calls the class's constructor and feeds it the dependencies you specify. This promotes what is called a "Good Citizen" object, or an object who is completely initialized upon construction.

  $c->add_service(
      Bread::Board::ConstructorInjection->new(
          name         => 'authenticator',
          class        => 'Authenticator',
          dependencies => {
              db_conn => Bread::Board::Dependency->new(service_path => 'db_conn'),
              logger  => Bread::Board::Dependency->new(service_path => 'logger'),
          }
      )
  );

Since Bread::Board is built both with L<Moose> and for use with L<Moose> objects, it makes the assumption here that the constructor takes named arguments. Here is our earlier authenticator service rewritten to use constructor injection. This is by far the simplest injection type as it requires little more then a class name and a HASH of dependencies.

=item Setter Injection

Bread::Board also supports Setter Injection. The idea behind setter injection is that for each component dependency a corresponding setter method must exist. This style has been popularized by the Spring java framework. I will be honest, I don't find this type of injection as useful as block of constructor, but it can come in handy if your object prefers you to call setters to initailize it. Here is a fairly contrived example using the L<JSON> module.

  $c->add_service(
      Bread::Board::SetterInjection->new(
          name         => 'json',
          class        => 'JSON',
          dependencies => {
              utf8   => Bread::Board::Literal->new( name => 'true', value => 1 )
              pretty => Bread::Board::Literal->new( name => 'true', value => 1 )
          }
      )
  );

Setter injection actually creates the object without passing any arguments to the constructor, then loops through the keys in the dependency HASH and treats each key as a method name, and each value as that method's argument. In this case, the above is the equivalent of doing:

   my $json = JSON->new;
   $json->utf8(1);
   $json->pretty(1);

You might have been wondering about the fact we didn't specify Bread::Board::Dependency objects in our dependency HASH, but instead supplied Bread::Board::Literal instances. Bread::Board::Literal is just another Service type that simply holds a literal value, or a constant. When dependencies are specified like this, Bread::Board internally converts them into Bread::Board::Dependency whose service is already resolved to that service.

=back

=head2 Hierarchal Containers

Up until now, we have see basic containers which only have a single level of components. As you application grows larger it may become useful to have a more hierarchal approach to your containers. Bread::Board::Container supports this behavior through it's many subcontainer methods. Here is an example of how we might re-arrange the previous examples using subcontainers.

  my $app_c = Bread::Board::Container->new( name => 'app' );

  my $db_c = Bread::Board::Container->new( name => 'database' );
  $db_c->add_service(
      Bread::Board::BlockInjection->new(
          name  => 'connection'
          block => sub {
              my $s = shift;
              return DBI->connect(
                  $s->param('dsn'),
                  $s->param('username'),
                  $s->param('password')
              );
          },
          dependencies => {
              dsn      => Bread::Board::Literal->new( name => 'dsn',      value => 'dbi:mysql:test' ),
              username => Bread::Board::Literal->new( name => 'username', value => 'user' ),
              password => Bread::Board::Literal->new( name => 'password', value => '****' ),
          }
      )
  );

  $app_c->add_sub_container( $db_c );

  my $log_c = Bread::Board::Container->new( name => 'logging' );
  $log_c->add_service( Bread::Board::Literal->new( name => 'log_file', value => '/var/log/app.log' ) );
  $log_c->add_service(
      Bread::Board::ConstructorInjection->new(
          name  => 'logger',
          class => 'Logger',
          dependencies => {
              log_file => Bread::Board::Dependency->new( service_path => 'log_file' )
          }
      )
  );

  $app_c->add_sub_container( $log_c );

  my $sec_c = Bread::Board::Container->new( name => 'security' );
  $sec_c->add_service(
      Bread::Board::ConstructorInjection->new(
          name         => 'authenticator',
          class        => 'Authenticator',
          dependencies => {
              db_conn => Bread::Board::Dependency->new(service_path => '../database/db_conn'),
              logger  => Bread::Board::Dependency->new(service_path => '../logging/logger'),
          }
      )
  );

  $app_c->add_sub_container( $sec_c );

  $app_c->add_service(
      Bread::Board::ConstructorInjection->new(
          name         => 'app',
          class        => 'Application',
          dependencies => {
              auth    => Bread::Board::Dependency->new(service_path => '/security/authenticator'),
              db_conn => Bread::Board::Dependency->new(service_path => '/database/db_conn'),
              logger  => Bread::Board::Dependency->new(service_path => '/logging/logger'),
          }
      )
  );

So as can be seen above, hierarchal containers can be used as a form of namespacing to better organize your Bread::Board configuration. As is shown with the 'authenticator' service, it is possible to address services outside of your container using path notation. In this case the 'authenticator' service makes the assumption that it's parent container has both a 'database' and a 'logging' sub-container and they contain a 'db_conn' and 'logger' service respecitively. And as is shown in the 'app' service, it is also possible to address services using an absolute path notation.

So, up until now we have been creating all our Bread::Board objects by hand. As you can tell, this is both verbose and tedious. To make your life easier, Bread::Board provides a simple I<sugar> layer over these objects. Here is the equivalent of the above Bread::Board configuration using the sugar layer.

  my $c = container 'app' => as {

      container 'database' => as {
          service 'connection' => (
              block => sub {
                  my $s = shift;
                  return DBI->connect(
                      $s->param('dsn'),
                      $s->param('username'),
                      $s->param('password')
                  );
              },
              dependencies => {
                  dsn      => ( service 'dsn'      => 'dbi:mysql:test' ),
                  username => ( service 'username' => 'user' ),
                  password => ( service 'password' => '****' ),
              }
          )
      };

      container 'logging' => as {
          service 'log_file' => '/var/log/app.log';
          service 'logger' => (
              class        => 'Logger',
              dependencies => {
                  log_file => depends_on('log_file'),
              }
          )
      };

      container 'security' => as {
          service 'authenticator' => (
              class => 'Authenticator',
              dependencies => {
                  db_conn => depends_on('../database/db_conn'),
                  logger  => depends_on('../logging/logger'),
              }
          )
      };

      service 'app' => (
          class => 'Application',
          dependencies => {
              auth    => depends_on('/security/authenticator'),
              db_conn => depends_on('/database/db_conn'),
              logger  => depends_on('/logging/logger'),
          }
      )
  };

=head2 Conclusion

Hopefully this has helped to introduce you the concepts in Bread::Board and give you an idea of what it might be able to provide you and your application.

=head1 EXPORTED FUNCTIONS

=over 4

=item I<container ($name, &body)>

=item I<as (&body)>

=item I<service ($name, $literal|%service_description)>

=item I<depends_on ($service_name)>

=item I<wire_names (@service_names)>

=item I<include ($file)>

=back

=head1 METHODS

=over 4

=item B<set_root_container ($container)>

=item B<meta>

=back

=head1 ACKNOWLEDGEMENTS

Thanks to Daisuke Maki for his contributions and for really
pushing the development of this module along.

Chuck "sprongie" Adams, for testing/using early (pre-release)
versions of this module, and some good suggestions for naming
it.

Matt "mst" Trout, for finally coming up with the best name
for this module.

=head1 SEE ALSO

=over 4

=item L<IOC>

Bread::Board is basically my re-write of IOC.

=item L<http://en.wikipedia.org/wiki/Breadboard>

=back

=head1 BUGS

All complex software has bugs lurking in it, and this module is no
exception. If you find a bug please either email me, or add the bug
to cpan-RT.

=head1 AUTHOR

Stevan Little E<lt>stevan@iinteractive.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright 2007-2010 by Infinity Interactive, Inc.

L<http://www.iinteractive.com>

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
