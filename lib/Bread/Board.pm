package Bread::Board;

use strict;
use warnings;
use Carp qw(confess);
use Scalar::Util qw(blessed);
# ABSTRACT: A solderless way to wire up your application components

use Bread::Board::Types;
use Bread::Board::ConstructorInjection;
use Bread::Board::SetterInjection;
use Bread::Board::BlockInjection;
use Bread::Board::Literal;
use Bread::Board::Container;
use Bread::Board::Container::Parameterized;
use Bread::Board::Dependency;
use Bread::Board::LifeCycle::Singleton;
use Bread::Board::Service::Inferred;
use Bread::Board::Service::Alias;

use Moose::Exporter 2.1200;
Moose::Exporter->setup_import_methods(
    as_is => [qw[
        as
        container
        depends_on
        service
        alias
        wire_names
        include
        typemap
        infer
        literal
    ]],
);

sub as (&) { $_[0] }

our $CC;
our $in_container;

sub set_root_container {
    confess "Can't set the root container when we're already in a container"
        if $in_container;
    $CC = shift;
}

sub container ($;$$) {
    my $name = shift;

    my $c;
    if (blessed $name) {
        confess 'an object used as a container must inherit from Bread::Board::Container or Bread::Board::Container::Parameterized'
            unless $name->isa('Bread::Board::Container') || $name->isa('Bread::Board::Container::Parameterized');

        confess 'container($object, ...) is not supported for parameterized containers'
            if scalar @_ > 1;

        # this is basically:
        # container( A::Bread::Board::Container->new, ... )
        # or someone using &container as a constructor
        $c = $name;

        # if we're in the context of another container
        # then we're a subcontainer of it
        $CC->add_sub_container($c) if defined $CC;
    }
    else {
        my $is_inheriting = $name =~ s/^\+//;
        confess "Inheriting containers isn't possible outside of the context of a container"
            if $is_inheriting && !defined $CC;

        # if we have more than 1 argument, then we are a parameterized
        # container, so we need to act accordingly
        if (scalar @_ > 1) {
            confess 'Declaring container parameters when inheriting is not supported'
                if $is_inheriting;

            my $param_names = shift;
            $c = Bread::Board::Container::Parameterized->new({
                name                    => $name,
                allowed_parameter_names => $param_names,
            });
        }
        else {
            $c = $is_inheriting
                ? $CC->fetch($name)
                : Bread::Board::Container->new({ name => $name });
        }

        # if we're in the context of another container
        # then we're a subcontainer of it, unless we're inheriting,
        # in which case we already got a parent
        $CC->add_sub_container($c) if !$is_inheriting && defined $CC;
    }

    my $body = shift;
    # if we have more arguments
    # then they are likely a body
    # and so we should execute it
    if (defined $body) {
        local $_  = $c;
        local $CC = $c;
        local $in_container = 1;
        $body->($c);
    }

    return $c;
}

sub include ($) {
    my $file = shift;
    if (my $ret = do $file) {
        return $ret;
    }
    else {
        confess "Couldn't compile $file: $@" if $@;
        confess "Couldn't open $file for reading: $!" if $!;
        confess "Unknown error when compiling $file "
              . "(or $file doesn't return a true value)";
    }
}

sub service ($@) {
    my $name = shift;
    my $s;

    my $is_inheriting = ($name =~ s/^\+//);

    if (scalar @_ == 1) {
        confess "Service inheritance doesn't make sense for literal services"
            if $is_inheriting;

        $s = Bread::Board::Literal->new(name => $name, value => $_[0]);
    }
    elsif (scalar(@_) % 2 == 0) {
        my %params = @_;

        my $class = $params{service_class};
        $class ||= defined $params{service_type} ? "Bread::Board::$params{service_type}Injection"
                  : exists $params{block}        ? 'Bread::Board::BlockInjection'
                  :                                'Bread::Board::ConstructorInjection';

        $class->does('Bread::Board::Service')
            or confess "The service class must do the Bread::Board::Service role";

        if ($is_inheriting) {
            confess "Inheriting services isn't possible outside of the context of a container"
                unless defined $CC;

            my $container = ($CC->isa('Bread::Board::Container::Parameterized') ? $CC->container : $CC);
            my $prototype_service;
            
            if (defined $params{parent_service}) {
                $prototype_service = $container->fetch($params{parent_service});
                delete $params{parent_service};
            }
            else {
                $prototype_service = $container->fetch($name);
            }

            confess sprintf(
                "Trying to inherit from service '%s', but found a %s",
                $name, blessed $prototype_service,
            ) unless $prototype_service->does('Bread::Board::Service');

            $s = $prototype_service->clone_and_inherit_params(
                service_class => $class,
                %params,
            );
        }
        else {
            $s = $class->new(name => $name, %params);
        }
    }
    else {
        confess "A service is defined by a name and either a single value or hash of parameters; you have supplied neither";
    }
    return $s unless defined $CC;
    $CC->add_service($s);
}

sub alias ($$@) {
    my $name = shift;
    my $path = shift;
    my %params = @_;

    my $s = Bread::Board::Service::Alias->new(
        name              => $name,
        aliased_from_path => $path,
        %params,
    );
    return $s unless defined $CC;
    $CC->add_service($s);
}

sub typemap ($@) {
    my $type = shift;

    (scalar @_ == 1)
        || confess "typemap takes a single argument";

    my $service;
    if (blessed $_[0]) {
        if ($_[0]->does('Bread::Board::Service')) {
            $service = $_[0];
        }
        elsif ($_[0]->isa('Bread::Board::Service::Inferred')) {
            $service = $_[0]->infer_service( $type );
        }
        else {
            confess $_[0] . " isn't a service";
        }
    }
    else {
        $service = $CC->fetch( $_[0] );
    }

    $CC->add_type_mapping_for( $type, $service );
}

sub infer {
    if (@_ == 1) {
        return Bread::Board::Service::Inferred->new(
            current_container => $CC,
            service           => $_[0],
            infer_params      => 1,
        );
    }
    else {
        my %params = @_;
        return Bread::Board::Service::Inferred->new(
            current_container => $CC,
            service_args      => \%params,
            infer_params      => 1,
        );
    }
}

sub wire_names { +{ map { $_ => depends_on($_) } @_ }; }

sub depends_on ($) {
    my $path = shift;
    Bread::Board::Dependency->new(service_path => $path);
}

my $LITERAL_ANON = 0;
sub literal($) {
    my $value = shift;
    Bread::Board::Literal->new(
        name => 'LITERAL_ANON_' . $LITERAL_ANON++,
        value => $value,
    );
}

1;

__END__

=head1 SYNOPSIS

  use Bread::Board;

  my $c = container 'MyApp' => as {

      service 'log_file_name' => "logfile.log";

      service 'logger' => (
          class        => 'FileLogger',
          lifecycle    => 'Singleton',
          dependencies => [ 'log_file_name' ],
          ]
      );

      container 'Database' => as {
          service 'dsn'      => "dbi:SQLite:dbname=my-app.db";
          service 'username' => "user234";
          service 'password' => "****";

          service 'dbh' => (
              block => sub {
                  my $s = shift;
                  require DBI;
                  DBI->connect(
                      $s->param('dsn'),
                      $s->param('username'),
                      $s->param('password'),
                  ) || die "Could not connect";
              },
              dependencies => [ 'dsn', 'username', 'password' ]
          );
      };

      service 'application' => (
          class        => 'MyApplication',
          dependencies => {
              logger => 'logger',
              dbh    => 'Database/dbh',
          }
      );

  };

  no Bread::Board; # removes keywords

  # get an instance of MyApplication
  # from the container
  my $app = $c->resolve( service => 'application' );

  # now user your MyApplication
  # as you normally would ...
  $app->run;

=head1 DESCRIPTION

Bread::Board is an inversion of control framework with a focus on
dependency injection and lifecycle management. It's goal is to
help you write more decoupled objects and components by removing
the need for you to manually wire those objects/components together.

Want to know more? See the L<Bread::Board::Manual>.

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

Loading this package will automatically load the rest of the packages needed by
your Bread::Board configuration.

=head1 EXPORTED FUNCTIONS

The functions of this package provide syntactic sugar to help you build your
Bread::Board configuration. You can build such a configuration by constructing
the objects manually instead, but your code may be more difficult to
understand.

=head2 C<container>

=head3 simple case

  container $name, \&body;

This function constructs and returns an instance of L<Bread::Board::Container>.
The (optional) C<&body> block may be used to add services or sub-containers
within the newly constructed container. Usually, the block is not passed
directly, but passed using the C<as> function.

For example,

  container 'MyWebApp' => as {
      service my_dispatcher => (
          class => 'MyWebApp::Dispatcher',
      );
  };

If C<$name> starts with C<'+'>, and the container is being declared inside
another container, then this declaration will instead extend an existing
container with the name C<$name> (without the C<'+'>).

=head3 from an instance

  container $container_instance, \&body

In many cases, subclassing L<Bread::Board::Container> is the easiest route to
getting access to this framework. You can do this and still get all the
benefits of the syntactic sugar for configuring that class by passing an
instance of your container subclass to C<container>.

You could, for example, configure your container inside the C<BUILD> method of
your class:

  package MyWebApp;
  use Moose;

  extends 'Bread::Board::Container';

  sub BUILD {
      my $self = shift;

      container $self => as {
          service dbh => ( ... );
      };
  }

=head3 with parameters

  container $name, \@parameters, \&body

A third way of using the C<container> function is to build a parameterized
container. These are useful as a way of providing a placeholder for parts of
the configuration that may be provided later. You may not use an instance
object in place of the C<$name> in this case.

For more detail on how you might use parameterized containers, see
L<Bread::Board::Manual::Concepts::Advanced/Parameterized Containers>.

=head2 C<as>

  as { some_code() };

This is just a replacement for the C<sub> keyword that is easier to read when
defining containers.

=head2 C<service>

  service $name, $literal;
  service $name, %service_description;

Within the C<as> blocks for your containers, you may construct services using
the C<service> function. This can construct several different kinds of services
based upon how it is called.

=head3 literal services

To build a literal service (a L<Bread::Board::Literal> object), just specify a
scalar value or reference you want to use as the literal value:

  # In case you need to adjust the gravitational constant of the Universe
  service gravitational_constant => 6.673E-11;

=head3 using injections

To build a service using one of the injection services, just fill in all the
details required to use that sort of injection:

  service search_service => (
      class => 'MyApp::Search',
      block => sub {
          my $s = shift;
          MyApp::Search->new($s->param('url'), $s->param('type'));
      },
      dependencies => {
          url => 'search_url',
      },
      parameters => {
          type => { isa => 'Str', default => 'text' },
      },
  );

The type of injection performed depends on the parameters used. You may use
the C<service_class> parameter to pick a specific injector class. For
instance, this is useful if you need to use L<Bread::Board::SetterInjection>
or have defined a custom injection service.  If you specify a C<block>, block
injection will be performed using L<Bread::Board::BlockInjection>. If neither
of these is present, constructor injection will be used with
L<Bread::Board::ConstructorInjection> (and you must provide the C<class>
option).

=head3 service dependencies

The C<dependencies> parameter takes a hashref of dependency names mapped to
L<Bread::Board::Dependency> objects, but there are several coercions and sugar
functions available to make specifying dependencies as easy as possible. The
simplest case is when the names of the services you're depending on are the
same as the names that the service you're defining will be accessing them with.
In this case, you can just specify an arrayref of service names:

  service foo => (
      dependencies => [ 'bar', 'baz' ],
      # ...
  );

If you need to use a different name, you can specify the dependencies as a
hashref instead:

  service foo => (
      dependencies => {
          dbh => 'foo_dbh',
      },
      # ...
  );

You can also specify parameters when depending on a parameterized service:

  service foo => (
      dependencies => [
          { bar => { bar_param => 1 } },
          'baz',
      ],
      # ...
  );

Finally, services themselves can also be specified as dependencies, in which
case they will just be resolved directly:

  service foo => (
      dependencies => {
          dsn => Bread::Board::Literal->new(
              name  => 'dsn',
              value => 'dbi:mysql:mydb',
          ),
      },
      # ...
  );

As a special case, an arrayref of dependencies will be interpreted as a service
which returns an arrayref containing the resolved values of those dependencies:

  service foo => (
      dependencies => {
          # items will resolve to [ $bar_service->get, $baz_service->get ]
          items => [
              'bar',
              Bread::Board::Literal->new(name => 'baz', value => 'BAZ'),
          ],
      },
      # ...
  );

=head3 inheriting and extending services

If the C<$name> starts with a C<'+'>, the service definition will instead
extend an existing service with the given C<$name> (without the C<'+'>). This
works similarly to the C<has '+foo'> syntax in Moose. It is most useful when
defining a container class where the container is built up in C<BUILD> methods,
as each class in the inheritance hierarchy can modify services defined in
superclasses. The C<dependencies> and C<parameters> options will be merged with
the existing values, rather than overridden. Note that literal services can't
be extended, because there's nothing to extend. You can still override them
entirely by declaring the service name without a leading C<'+'>.

=head2 C<literal>

  literal($value);

Creates an anonymous L<Bread::Board::Literal> object with the given value.

          service 'dbh' => (
              block => sub {
                  my $s = shift;
                  require DBI;
                  DBI->connect(
                      $s->param('dsn'),
                      $s->param('username'),
                      $s->param('password'),
                  ) || die "Could not connect";
              },
              dependencies => {
                dsn      => literal 'dbi:SQLite:somedb',
                username => literal 'foo',
                password => literal 'password',

              },
          );

=head2 C<depends_on>

  depends_on($service_path);

The C<depends_on> function creates a L<Bread::Board::Dependency> object for the
named C<$service_path> and returns it.

=head2 C<wire_names>

  wire_names(@service_names);

This function is just a shortcut for passing a hash reference of dependencies
into the service. It is not typically needed, since Bread::Board can usually
understand what you mean - these declarations are all equivalent:

  service foo => (
      class => 'Pity::TheFoo',
      dependencies => {
          foo => depends_on('foo'),
          bar => depends_on('bar'),
          baz => depends_on('baz'),
      },
  );

  service foo => (
      class => 'Pity::TheFoo',
      dependencies => wire_names(qw( foo bar baz )),
  );

  service foo => (
      class => 'Pity::TheFoo',
      dependencies => {
          foo => 'foo',
          bar => 'bar',
          baz => 'baz',
      },
  );

  service foo => (
      class => 'Pity::TheFoo',
      dependencies => [ qw(foo bar baz ) ],
  );

=head2 C<typemap>

  typemap $type, $service;
  typemap $type, $service_path;

This creates a type mapping for the named type. Typically, it is paired with
the C<infer> call like so:

  typemap 'MyApp::Model::UserAccount' => infer;

For more details on what type mapping is and how it works, see
L<Bread::Board::Manual::Concepts::Typemap>.

=head2 C<infer>

  infer;
  infer(%hints);

This is used with C<typemap> to help create the typemap inference. It can be
used with no arguments to do everything automatically. However, in some cases,
you may want to pass a service instance as the argument or a hash of service
arguments to change how the type map works. For example, if your type needs to
be constructed using a setter injection, you can use an inference similar to
this:

  typemap 'MyApp::Model::UserPassword' => infer(
      service_class => 'Bread::Board::SetterInjection',
  );

For more details on what type mapping is and how it works, see
L<Bread::Board::Manual::Concepts::Typemap>.

=head2 C<include>

  include $file;

This is a shortcut for loading a Bread::Board configuration from another file.

  include "filename.pl";

The above is pretty much identical to running:

  do "filename.pl";

However, you might find it more readable to use C<include>.

=head2 C<alias>

  alias $service_name, $service_path, %service_description;

This helper allows for the creation of L<service
aliases|Bread::Board::Service::Alias>, which allows you to define a
service in one place and then reuse that service with a different name
somewhere else. This is sort of like a symbolic link for
services. Aliases will be L<resolved
recursively|Bread::Board::Traversable/fetch>, so an alias can alias an
alias.

For example,

  service file_logger => (
      class => 'MyApp::Logger::File',
  );

  alias my_logger => 'file_logger';

=head1 OTHER FUNCTIONS

These are not exported, but might be helpful to you.

=head2 C<set_root_container>

  set_root_container $container;

You may use this to set a top-level root container for all container
definitions.

For example,

  my $app = container MyApp => as { ... };

  Bread::Board::set_root_container($app);

  my $config = container Config => as { ... };

Here the C<$config> container would be created as a sub-container of C<$app>.

=head1 ACKNOWLEDGEMENTS

Thanks to Daisuke Maki for his contributions and for really
pushing the development of this module along.

Chuck "sprongie" Adams, for testing/using early (pre-release)
versions of this module, and some good suggestions for naming
it.

Matt "mst" Trout, for finally coming up with the best name
for this module.

Gianni "dakkar" Ceccarelli for writing lots of documentation, and
Net-a-Porter.com for paying his salary while he was doing it.

=head1 ARTICLES

L<Bread::Board is the right tool for this job|http://domm.plix.at/perl/2013_04_bread_board_is_the_right_rool_for_this_job.html>
Thomas Klausner showing a use-case for Bread::Board.

=head1 SEE ALSO

=over 4

=item L<Bread::Board::Declare>

This provides more powerful syntax for writing Bread::Board container classes.

=item L<IOC>

Bread::Board is basically my re-write of IOC.

=item L<http://en.wikipedia.org/wiki/Breadboard>

=back
