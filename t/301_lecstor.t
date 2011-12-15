#!/usr/bin/perl

use strict;
use warnings;

use Test::More;
use Test::Fatal;

use Bread::Board;
use Bread::Board::Container;


my $exception = exception { container (bless {}, 'NameObject') };
like( $exception, qr/^Attribute \(name\)/, "exception begins with: Attribute (name)" );


ok ( (container 'MyApp' => as { service 'service_name',
                                  'service_type' => 'Block',
                                  'block' => sub{} } ), 'hmmm' );

my $c = Bread::Board::Container->new(name => '/');
isa_ok($c, 'Bread::Board::Container');


ok ( (container $c), 'name is object' );


$exception = exception{ container $c, 'summat', 'summat else' };
like( $exception, qr/^container\(\$object, \.\.\.\) is not supported/, 'exception begins with: container($object, ...) is not supported' );


$exception = exception{ 
    container 'MyApp' => as { service 'service_name', 'summat', 'summat else', 'summat else again' }
};
like( $exception, qr/^I don't understand/, 'exception begins with: I don\'t understand' );

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


$exception = exception{ 
    typemap ('Type')
};
like( $exception, qr/^Too many \(or too few\)/, 'exception begins with: Too many (or too few)' );


$exception = exception{ 
    typemap ('Type', MyNonService->new)
};
like( $exception, qr/^No idea what to do with a/, 'exception begins with: No idea what to do with a' );


done_testing;
