use strict;
use warnings;
use Test::More;

use Bread::Board ();

ok !Bread::Board->can("new"), 'Bread::Board has no new() method';

done_testing;

