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

use Moose::Exporter;
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
    ]],
);

sub as (&) { $_[0] }

our $CC;

sub set_root_container {
    (defined $CC && confess "Cannot set the root container, CC is already defined $CC");
    $CC = shift;
}

sub container ($;$$) {
    my $name        = shift;

    my $name_is_obj = 0;
    if (blessed $name){
        confess 'an object used as a container must inherit from Bread::Board::Container'
            unless $name->isa('Bread::Board::Container');
        $name_is_obj = 1;
    }

    my $c;
    if ( scalar @_ == 0 ) {
        if ( $name_is_obj ) {
            # this is basically:
            # container( A::Bread::Board::Container->new )
            # which should work
            $c = $name;
        }
        else {
            # otherwise it is just
            # someone using &container
            # as a constructor
            return Bread::Board::Container->new(
                name => $name
            );
        }
    }
    # if we have one more arg
    # then we have block to
    # follow us, that we want
    # to use to create stuff
    # with.
    elsif ( scalar @_ == 1 ) {
        $c = $name_is_obj
            ? $name
            : Bread::Board::Container->new( name => $name );
    }
    # if we have even more
    # then we are a parameterized
    # container, so we need to
    # act accordingly
    else {
        confess 'container($object, ...) is not supported for parameterized containers'
            if $name_is_obj;
        my $param_names = shift;
        $c = Bread::Board::Container::Parameterized->new(
            name                    => $name,
            allowed_parameter_names => $param_names,
        )
    }

    # now, if we are here, then
    # we obviously have something
    # more to contribute to the
    # container world ...

    # if we already have a root
    # container, then we are a
    # subcontainer of it ...
    if (defined $CC) {
        $CC->add_sub_container($c);
    }


    my $body = shift;
    # if we have more arguments
    # then they are likely a body
    # and so we should execute it
    if (defined $body) {
        local $_  = $c;
        local $CC = $c;
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
        confess "$file compiles to false.";
    }
}

sub service ($@) {
    my $name = shift;
    my $s;
    if (scalar @_ == 1) {
        $s = Bread::Board::Literal->new(name => $name, value => $_[0]);
    }
    elsif (scalar(@_) % 2 == 0) {
        my %params = @_;
        if ($params{service_class}) {
            ($params{service_class}->does('Bread::Board::Service'))
                || confess "The service class must do the Bread::Board::Service role";
            $s = $params{service_class}->new(name => $name, %params);
        }
        else {
            my $type = $params{service_type};
            $type = (exists $params{block} ? 'Block' : 'Constructor') unless $type;
            $s = "Bread::Board::${type}Injection"->new(name => $name, %params);
        }
    }
    else {
        confess "A service is defined by a name and either a single value or hash of\nparameters, you have supplied neither with:\n\t@_";
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
        || confess "typemap has one argument at a time";

    my $service;
    if (blessed $_[0]) {
        if ($_[0]->does('Bread::Board::Service')) {
            $service = $_[0];
        }
        elsif ($_[0]->isa('Bread::Board::Service::Inferred')) {
            $service = $_[0]->infer_service( $type );
        }
        else {
            confess $_[0] . " doesn't do Bread::Board::Service and isn't a Bread::Board::Service::Inferred. No idea what to do with it.";
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

1;

__END__

=pod

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

=over 4

=item I<container ($name, &body)>

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

=item I<container ($container_instance, &body)>

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

=item I<container ($name, [ @parameters ], &body)>

A third way of using the C<container> function is to build a parameterized
container. These are useful as a way of providing a placeholder for parts of
the configuration that may be provided later. You may not use an instance
object in place of the C<$name> in this case.

For more detail on how you might use parameterized containers, see
L<Bread::Board::Manual::Concepts::Advanced/Parameterized Containers>.

=item I<as (&body)>

This is just a replacement for the C<sub> keyword that is easier to read when
defining containers.

=item I<service ($name, $literal | %service_description)>

Within the C<as> blocks for your containers, you may construct services using
the C<service> function. This can construct several different kinds of services
based upon how it is called.

To build a literal service (a L<Bread::Board::Literal> object), just specify a
scalar value or reference you want to use as the literal value:

  # In case you need to adjust the gravitational constant of the Universe
  service gravitational_constant => 6.673E-11;

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

=item I<depends_on ($service_path)>

The C<depends_on> function creates a L<Bread::Board::Dependency> object for the
named C<$service_path> and returns it.

=item I<wire_names (@service_names)>

This function is just a shortcut for passing a hash reference of dependencies
into the service.

  service foo => (
      class => "Pity::TheFoo',
      dependencies => wire_names(qw( foo bar baz )),
  );

The above is identical to:

  service foo => (
      class => 'Pity::TheFoo',
      dependencies => {
          foo => depends_on('foo'),
          bar => depends_on('bar'),
          baz => depends_on('baz'),
      },
  );

=item I<typemap ($type, $service | $service_path)>

This creates a type mapping for the named type. Typically, it is paired with
the C<infer> call like so:

  typemap 'MyApp::Model::UserAccount' => infer;

For more details on what type mapping is and how it works, see
L<Bread::Board::Manual::Concepts::Typemap>.

=item I<infer (?%hints)>

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

=item I<include ($file)>

This is a shortcut for loading a Bread::Board configuration from another file.

  include "filename.pl";

The above is pretty much identical to running:

  do "filename.pl";

However, you might find it more readable to use C<include>.

=item I<alias ($service_name, $service_path, %service_description)>

This helper allows for the creation of service aliases, which allows you to
define a service in one place and then reuse that service with a different name
somewhere else. This is sort of like a symbolic link for services. Aliases will
be resolved recursively, so an alias can alias an alias.

For example,

  service file_logger => (
      class => 'MyApp::Logger::File',
  );

  alias my_logger => 'file_logger';

=back

=head1 OTHER FUNCTIONS

These are not exported, but might be helpful to you.

=over 4

=item I<set_root_container ($container)>

You may use this to set a top-level root container for all container
definitions.

For example,

  my $app = container MyApp => as { ... };

  Bread::Board::set_root_container($app);

  my $config = container Config => as { ... };

Here the C<$config> container would be created as a sub-container of C<$app>.

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

=item L<Bread::Board::Declare>

This provides more powerful syntax for writing Bread::Board container classes.

=item L<IOC>

Bread::Board is basically my re-write of IOC.

=item L<http://en.wikipedia.org/wiki/Breadboard>

=back

=head1 BUGS

All complex software has bugs lurking in it, and this module is no
exception. If you find a bug please either email me, or add the bug
to cpan-RT.

=cut
