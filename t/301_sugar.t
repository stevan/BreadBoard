#!/usr/bin/perl

use strict;
use warnings;

use Test::More;
use Test::Fatal;

use Bread::Board;


my $exception = exception { container (bless {}, 'NameObject') };
like( $exception, qr/^an object used as a container/, "exception begins with: an object used as a container" );


ok ( (container 'MyApp' => as { service 'service_name',
                                  'service_type' => 'Block',
                                  'block' => sub{} } ), 'set service with service type name' );


my $c = container 'Application';
isa_ok($c, 'Bread::Board::Container');


ok ( (container $c), 'set container with object' );


$exception = exception{ container $c, 'thing1', 'thing2' };
like( $exception, qr/^container\(\$object, \.\.\.\) is not supported/, 'exception begins with: container($object, ...) is not supported' );


$exception = exception{ 
    container 'MyApp' => as { service 'service_name', 'thing1', 'thing2', 'trouble' }
};
like( $exception, qr/^A service is defined by/, 'exception begins with: A service is defined by' );

{
    package MyNonService;
    use Moose;
}

$exception = exception{ 
    container 'MyApp' => as {
        service 'service_name',
        'service_class' => 'MyNonService',
    }
};
like( $exception, qr/^The service class must do the Bread::Board::Service role/, 'exception begins with: The service class must do the Bread::Board::Service role' );


$exception = exception{ typemap ('Type') };
like( $exception, qr/^typemap takes a single argument/,
      "exception begins with: typemap takes a single argument" );


$exception = exception{
    typemap ('Type', MyNonService->new)
};
like( $exception, qr/isn't a service/, "exception contains: isn't a service" );


done_testing;
