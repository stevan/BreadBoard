use strict;
use warnings;
use inc::Module::Install 0.91;
use Module::Install::AuthorTests;

name 'Bread-Board';
all_from 'lib/Bread/Board.pm';
license 'perl';

# prereqs
requires 'Moose'                    => '0.87';
requires 'Class::MOP'               => '0.91';
requires 'MooseX::Param'            => '0.02';
requires 'MooseX::Clone'            => '0.04';
requires 'MooseX::AttributeHelpers' => '0.21';
requires 'MooseX::Params::Validate' => '0.12';

# things the tests need
build_requires 'Test::More'      => '0.62';
build_requires 'Test::Exception' => '0.21';

tests('t/*.t');
author_tests('t/author/*.t');

WriteAll();

