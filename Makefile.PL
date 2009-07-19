use strict;
use warnings;
use inc::Module::Install;

name 'Bread-Board';
all_from 'lib/Bread/Board.pm';
license 'perl';

# prereqs
requires 'Moose'                    => '0.87';
requires 'MooseX::Param'            => '0.02';
requires 'MooseX::Clone'            => '0.04';
requires 'MooseX::AttributeHelpers' => '0.21';
requires 'MooseX::Params::Validate' => '0.12';
requires 'Sub::Exporter'            => '0.982';

# things the tests need
build_requires 'Test::More'      => '0.62';
build_requires 'Test::Exception' => '0.21';

tests('t/*.t');

WriteAll();

